
library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(plotly)


source("getdata_function.R")
data <- getdata_dummy()




# UI function
ui <- page_sidebar(
  title = "Age distribution",
  sidebar = sidebar(
    
    # Filter by studyID
    selectInput(
      inputId = "siteName",
      label = "Population:",
      choices = sort(unique(data$siteName)),
      selected = unique(data$siteName)[1]
    ),
    
    # Filter by speciesID
    selectInput(
      inputId = "vernacularName",
      label = "Species:",
      choices = sort(unique(data$vernacularName)),
      selected = unique(data$vernacularName)[1]
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
  
  plotlyOutput("distPlot")
)



# SERVER function
server <- function(input, output, session) {
  
  # ---- GLOBAL FIXED AGE SCALE ----
  all_ages <- sort(unique(data$minimumAge))
  all_ages_factor <- factor(all_ages, levels = all_ages)
  
  # ---- UPDATE SPECIES WHEN studyID CHANGES ----
  observeEvent(input$siteName, {
    
    species_available <- data %>%
      filter(
        siteName == input$siteName,
        !is.na(minimumAge)                  # only species with valid ages
      ) %>%
      pull(vernacularName) %>%
      unique() %>%
      sort()
    
    if (length(species_available) == 0) species_available <- ""
    
    updateSelectInput(
      session,
      "vernacularName",
      choices = species_available,
      selected = species_available[1]
    )
  })
  
  # ---- UPDATE YEAR SLIDER WHEN studyID OR speciesID CHANGES ----
  observeEvent(list(input$siteName, input$vernacularName), {
    
    years_available <- data %>%
      filter(
        siteName == input$siteName,
        vernacularName == input$vernacularName,
        !is.na(minimumAge)
      ) %>%
      pull(captureYear) %>%
      unique() %>%
      sort()
    
    # No valid rows → reset slider safely
    if (length(years_available) == 0) {
      updateSliderInput(
        session,
        "year",
        min = 0, max = 0, value = 0
      )
      return()
    }
    
    updateSliderInput(
      session,
      "year",
      min = min(years_available),
      max = max(years_available),
      value = min(years_available)
    )
  })
  
  # ---- PLOT ----
  output$distPlot <- renderPlotly({
    
    # Filter data; avoid invalid year=0 cases
    df <- data %>%
      filter(
        siteName == input$siteName,
        vernacularName == input$vernacularName,
        !is.na(minimumAge),
        if (input$year > 0) captureYear == input$year else TRUE
      ) %>%
      group_by(observedSex, minimumAge) %>%
      summarise(count = sum(n), .groups = "drop") %>%
      mutate(
        sex3 = case_when(
          observedSex == "M" ~ "M",
          observedSex == "F" ~ "F",
          TRUE               ~ "U"
        ),
        minimumAge = factor(minimumAge, levels = levels(all_ages_factor))
      )
    
    # If no data → return empty plot safely
    if (nrow(df) == 0) {
      return(
        plotly_empty(type = "scatter", mode = "none") %>%
          layout(title = "No data available for this combination")
      )
    }
    
    # Always force sex3 to have M F U levels
    df <- df %>%
      mutate(sex3 = factor(sex3, levels = c("F", "M", "U")))
    
    # Split unknown sex
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
        )
      )
    
    # Prepare for plotting
    df_plot <- bind_rows(
      df %>% filter(sex3 %in% c("M","U")) %>% 
        transmute(x = count_left, y = minimumAge, sex3 = sex3, count = count),
      df %>% filter(sex3 %in% c("F","U")) %>% 
        transmute(x = count_right, y = minimumAge, sex3 = sex3, count = count)
    )
    
    # ---- COMPUTE PERCENTAGE ----
    total_count <- sum(abs(df_plot$x))
    df_plot <- df_plot %>%
      mutate(percent = round(abs(x) / total_count * 100, 1))
    
    # ---- GGPlot ----
    p <- ggplot(df_plot, aes(
      x = x,
      y = y,
      fill = sex3,
      text = paste0(
        "Age: ", y,
        "<br>Count: ", count,
        "<br>Percent: ", percent, "%"
      )
    )) +
      geom_col(width = 0.8) +
      scale_x_continuous(labels = abs) +
      scale_y_discrete(drop = FALSE, limits = levels(all_ages_factor)) +
      scale_fill_manual(
        values = c("F" = "skyblue", "M" = "salmon", "U" = "grey50"),
        breaks = c("F", "M", "U"),
        labels = c("Female", "Male", "Unknown")
      ) +
      labs(
        x = "Count",
        y = "Age (years)",
        title = paste("Age Pyramid —",
                      input$vernacularName, "|",
                      input$siteName, "| Year", input$year),
        fill = "Sex"
      ) +
      theme_minimal(base_size = 15)
    
    ggplotly(p, tooltip = "text")
  })
}





# RUN APP
shinyApp(ui = ui, server = server)
