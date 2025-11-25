
library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)


data <- read.csv("data/individual_data.csv")



# UI
ui <- page_sidebar(
  title = "Age distribution",
  sidebar = sidebar(
    
    # Filter by studyID
    selectInput(
      inputId = "studyID",
      label = "Population (studyID):",
      choices = sort(unique(data$studyID)),
      selected = unique(data$studyID)[1]
    ),
    
    # Filter by speciesID
    selectInput(
      inputId = "speciesID",
      label = "Species:",
      choices = sort(unique(data$speciesID)),
      selected = unique(data$speciesID)[1]
    ),
    
    # Year slider
    sliderInput(
      inputId = "year",
      label = "Select year:",
      min = min(data$captureYear),
      max = max(data$captureYear),
      value = min(data$captureYear),
      step = 1,
      sep = ""
    )
  ),
  
  plotOutput("distPlot")
)



# SERVER
server <- function(input, output, session) {
  
  # Update species dropdown when studyID changes
  observeEvent(input$studyID, {
    species_available <- data %>%
      filter(studyID == input$studyID) %>%
      pull(speciesID) %>%
      unique() %>%
      sort()
    
    updateSelectInput(
      session,
      "speciesID",
      choices = species_available,
      selected = species_available[1]
    )
  })
  
  # Update year slider for combinations of studyID or speciesID
  observeEvent(list(input$studyID, input$speciesID), {
    years_available <- data %>%
      filter(
        studyID == input$studyID,
        speciesID == input$speciesID
      ) %>%
      pull(captureYear) %>%
      unique() %>%
      sort()
    
    updateSliderInput(
      session,
      "year",
      min = min(years_available),
      max = max(years_available),
      value = min(years_available)
    )
  })
  
  # Render pyramid
  output$distPlot <- renderPlot({
    
    df <- data %>%
      filter(
        studyID == input$studyID,
        speciesID == input$speciesID,
        captureYear == input$year,
        !is.na(minimumAge)    # exclude NA ages
      ) %>%
      group_by(observedSex, minimumAge) %>%
      summarise(count = sum(n), .groups = "drop") %>%
      mutate(
        sex3 = case_when(
          observedSex == "M" ~ "M",
          observedSex == "F" ~ "F",
          TRUE               ~ "U"   # Unknown sex
        )
      )
    
    # Split unknown sex counts to both sides
    df <- df %>%
      mutate(
        count_left = case_when(
          sex3 == "M" ~ -count,
          sex3 == "U" ~ -floor(count/2),
          TRUE        ~ 0
        ),
        count_right = case_when(
          sex3 == "F" ~ count,
          sex3 == "U" ~ ceiling(count/2),
          TRUE        ~ 0
        ),
        minimumAge = factor(minimumAge, levels = sort(unique(minimumAge)))
      )
    
    # Prepare dataframe for plotting
    df_plot <- bind_rows(
      df %>% filter(sex3 %in% c("M","U")) %>% transmute(x = count_left, y = minimumAge, sex3 = sex3),
      df %>% filter(sex3 %in% c("F","U")) %>% transmute(x = count_right, y = minimumAge, sex3 = sex3)
    )
    
    ggplot(df_plot, aes(x = x, y = y, fill = sex3)) +
      geom_col(width = 0.8) +
      scale_x_continuous(labels = abs) +
      scale_fill_manual(
        values = c("M" = "salmon", "F" = "skyblue", "U" = "grey50"),
        breaks = c("M","F","U"),
        labels = c("Male","Female","Unknown")
      ) +
      labs(
        x = "Count",
        y = "Age (years)",
        title = paste(
          "Age Pyramid —", input$speciesID, "|", input$studyID, "| Year", input$year
        ),
        fill = "Sex"
      ) +
      theme_minimal(base_size = 15)
    
    
  })
}

# Run app
shinyApp(ui = ui, server = server)
