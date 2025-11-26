
library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(plotly)


source("getdata_function.R", local=TRUE)
data <- getdata_dummy()


# UI function
ui <- page_sidebar(
  title = "Sex-age pyramid",
  sidebar = sidebar(
    # Filter by study
    selectInput(
      inputId = "siteName",
      label = "Population:",
      choices = sort(unique(data$siteName)),
      selected = unique(data$siteName)[1]
    ),
    
    # Filter by species
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
  # Constants - Create fixed age levels from the entire dataset
  all_possible_ages <- sort(unique(data$minimumAge))
  fixed_age_levels <- factor(all_possible_ages, levels = all_possible_ages)
  
  sex_levels <- c("F", "M", "U")
  sex_labels <- c("Female", "Male", "Unknown")
  sex_colors <- c("Female" = "skyblue", "Male" = "salmon", "Unknown" = "grey50")
  
  # Reactive updates
  observeEvent(input$siteName, {
    species_available <- data %>%
      filter(siteName == input$siteName, !is.na(minimumAge)) %>%
      pull(vernacularName) %>% unique() %>% sort()
    
    updateSelectInput(
      session, "vernacularName",
      choices = species_available,
      selected = species_available[1]
    )
  })
  
  observeEvent(list(input$siteName, input$vernacularName), {
    years_available <- data %>%
      filter(siteName == input$siteName,
             vernacularName == input$vernacularName,
             !is.na(minimumAge)) %>%
      pull(captureYear) %>% unique() %>% sort()
    
    if (length(years_available) == 0) years_available <- 0
    
    updateSliderInput(
      session, "year",
      min = min(years_available),
      max = max(years_available),
      value = min(years_available)
    )
  })
  
  # Plot
  output$distPlot <- renderPlotly({
    # Filter data
    df <- data %>%
      filter(siteName == input$siteName,
             vernacularName == input$vernacularName,
             !is.na(minimumAge),
             if (input$year > 0) captureYear == input$year else TRUE) %>%
      group_by(observedSex, minimumAge) %>%
      summarise(count = sum(n), .groups = "drop") %>%
      mutate(
        sex3 = case_when(
          observedSex == "M" ~ "M",
          observedSex == "F" ~ "F",
          TRUE ~ "U"
        ),
        # Use the fixed age levels
        minimumAge = factor(minimumAge, levels = levels(fixed_age_levels))
      )
    
    # Return empty plot if no data
    if (nrow(df) == 0) {
      return(
        plotly_empty(type = "scatter", mode = "none") %>%
          layout(title = "No data available for this year")
      )
    }
    
    # Calculate percentages
    total_count <- sum(df$count)
    df <- df %>%
      group_by(minimumAge) %>%
      mutate(percent_age = sum(count) / total_count * 100) %>%
      ungroup()
    
    # Split counts for pyramid
    df_plot <- df %>%
      mutate(
        count_left = case_when(
          sex3 == "M" ~ -count,
          sex3 == "U" ~ -floor(count / 2),
          TRUE ~ 0
        ),
        count_right = case_when(
          sex3 == "F" ~ count,
          sex3 == "U" ~ ceiling(count / 2),
          TRUE ~ 0
        ),
        sex_label = case_when(
          sex3 == "F" ~ "Female",
          sex3 == "M" ~ "Male", 
          sex3 == "U" ~ "Unknown"
        )
      )
    
    # Prepare plotting dataframe
    df_plot <- bind_rows(
      df_plot %>%
        filter(sex3 %in% c("M", "U")) %>%
        transmute(x = count_left, y = minimumAge, sex_label, count, percent_age),
      df_plot %>%
        filter(sex3 %in% c("F", "U")) %>%
        transmute(x = count_right, y = minimumAge, sex_label, count, percent_age)
    )
    
    # Add faded filler for missing sexes
    present_sexes <- unique(df_plot$sex_label[df_plot$x != 0])
    missing_sexes <- setdiff(sex_labels, present_sexes)
    
    if (length(missing_sexes) > 0) {
      filler <- data.frame(
        sex_label = missing_sexes,
        y = factor(levels(fixed_age_levels)[1], levels = levels(fixed_age_levels)),
        x = 0, count = 0, percent_age = 0, alpha = 0.15
      )
      df_plot <- bind_rows(mutate(df_plot, alpha = 1), filler)
    } else {
      df_plot$alpha <- 1
    }
    
    # Create plot with FIXED y-axis scale
    p <- ggplot(df_plot, aes(
      x = x, y = y, fill = sex_label, alpha = alpha,
      text = paste0("Age: ", y, "<br>Count: ", count, 
                    "<br>Percent: ", sprintf("%.1f", percent_age), "%")
    )) +
      geom_col(width = 0.8) +
      scale_alpha_identity() +
      scale_x_continuous(labels = abs) +
      scale_y_discrete(
        drop = FALSE,
        limits = levels(fixed_age_levels),  # Use the fixed levels
        breaks = c(levels(fixed_age_levels)[1], levels(fixed_age_levels)[length(levels(fixed_age_levels))])  # Only show min and max
      ) +
      scale_fill_manual(values = sex_colors, breaks = sex_labels, drop = FALSE) +
      labs(x = "Count", y = "Age (years)", 
           title = paste(input$vernacularName, "|", input$siteName, "| Year", input$year),
           fill = "Sex") +
      theme_minimal(base_size = 15)
    
    # Convert to Plotly and adjust legend opacity
    p_ly <- ggplotly(p, tooltip = "text")
    
    # Apply opacity to missing sexes in legend
    for (i in seq_along(p_ly$x$data)) {
      if (!is.null(p_ly$x$data[[i]]$name) && p_ly$x$data[[i]]$name %in% missing_sexes) {
        p_ly$x$data[[i]]$marker$opacity <- 0.15
      }
    }
    
    p_ly
  })
}


# RUN APP
shinyApp(ui = ui, server = server)