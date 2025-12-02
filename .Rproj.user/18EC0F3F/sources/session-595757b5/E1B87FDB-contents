library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(plotly)
library(here)

source(here::here("getdata_function.R"))
data  <- getdata_dummy()


# UI function
ui <- page_sidebar(
  title = "Sex-age pyramid",
  sidebar = sidebar(
    
    # Filter by species
    selectInput(
      inputId = "vernacularName",
      label = "Species:",
      choices = sort(unique(data$vernacularName)),
      selected = unique(data$vernacularName)[1]
    ),
    
    # Filter by study
    selectInput(
      inputId = "siteName",
      label = "Population:",
      choices = sort(unique(data$siteName)),
      selected = unique(data$siteName)[1]
    ),
    
    # Year slider
    sliderInput(
      inputId = "year",
      label = "Select year:",
      min = min(data$captureYear),
      max = max(data$captureYear),
      value = min(data$captureYear),
      step = 1,
      round = TRUE,
      animate = TRUE,
      sep = ""
    )
  ),
  
  plotlyOutput("distPlot")
)


# SERVER function
server <- function(input, output, session) {
  
  # ------------------------------------------
  # FIXED AGE LEVELS (global)
  # ------------------------------------------
  all_possible_ages <- sort(unique(data$minimumAge))
  fixed_age_levels <- factor(all_possible_ages, levels = all_possible_ages)
  
  sex_levels <- c("F", "M", "U")
  sex_labels <- c("Female", "Male", "Unknown")
  sex_colors <- c("Female" = "skyblue", "Male" = "salmon", "Unknown" = "grey50")
  
  # ------------------------------------------
  # PRECOMPUTE FIXED MAX COUNTS PER POP×SPECIES
  # ------------------------------------------
  max_counts <- data %>%
    group_by(siteName, vernacularName) %>%
    summarise(max_count = max(n), .groups = "drop")
  
  
  # ------------------------------------------
  # Reactive UI updates
  # ------------------------------------------
  observeEvent(input$vernacularName, {
    pop_available <- data %>%
      filter(vernacularName == input$vernacularName, !is.na(minimumAge)) %>%
      pull(siteName) %>% unique() %>% sort()
    
    updateSelectInput(
      session, "siteName",
      choices = pop_available,
      selected = pop_available[1]
    )
  })
  
  observeEvent(list(input$vernacularName, input$siteName), {
    years_available <- data %>%
      filter(vernacularName == input$vernacularName,
             siteName == input$siteName,
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
  
  
  # ------------------------------------------
  # MAIN PLOT
  # ------------------------------------------
  output$distPlot <- renderPlotly({
    
    # Filter actual selected-year data
    df <- data %>%
      filter(vernacularName == input$vernacularName,
             siteName == input$siteName,
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
        minimumAge = factor(minimumAge, levels = levels(fixed_age_levels))
      )
    
    if (nrow(df) == 0) {
      return(
        plotly_empty(type = "scatter", mode = "none") %>%
          layout(title = "No data available for this year")
      )
    }
    
    
    # ------------------------------------------
    # CALCULATE PERCENTAGES
    # ------------------------------------------
    total_count <- sum(df$count)
    df <- df %>%
      group_by(minimumAge) %>%
      mutate(percent_age = sum(count) / total_count * 100) %>%
      ungroup()
    
    
    # ------------------------------------------
    # SPLIT INTO LEFT/RIGHT FOR PYRAMID
    # ------------------------------------------
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
    
    df_plot <- bind_rows(
      df_plot %>%
        filter(sex3 %in% c("M", "U")) %>%
        transmute(x = count_left, y = minimumAge, sex_label, count, percent_age),
      
      df_plot %>%
        filter(sex3 %in% c("F", "U")) %>%
        transmute(x = count_right, y = minimumAge, sex_label, count, percent_age)
    )
    
    
    # ------------------------------------------
    # FIX: Get fixed max for this pop × species
    # ------------------------------------------
    fixed_max <- max_counts %>%
      filter(vernacularName == input$vernacularName,
             siteName == input$siteName,) %>%
      pull(max_count)
    
    if (length(fixed_max) == 0 || is.na(fixed_max)) fixed_max <- 1
    
    
    # ------------------------------------------
    # ADD FADED FILLER FOR MISSING SEXES
    # ------------------------------------------
    present_sexes <- unique(df_plot$sex_label[df_plot$x != 0])
    missing_sexes <- setdiff(sex_labels, present_sexes)
    
    if (length(missing_sexes) > 0) {
      filler <- data.frame(
        sex_label = missing_sexes,
        y = factor(levels(fixed_age_levels)[1], levels = levels(fixed_age_levels)),
        x = 0, count = 0, percent_age = 0, alpha = 0.15
      )
      df_plot$alpha <- 1
      df_plot <- bind_rows(df_plot, filler)
    } else {
      df_plot$alpha <- 1
    }
    
    
    # ------------------------------------------
    # BUILD GGplot WITH FIXED X SCALE
    # ------------------------------------------
    p <- ggplot(df_plot, aes(
      x = x, y = y, fill = sex_label, alpha = alpha,
      text = paste0("Age: ", y, "<br>Count: ", count,
                    "<br>Percent: ", sprintf("%.1f", percent_age), "%")
    )) +
      geom_col(width = 0.8) +
      scale_alpha_identity() +
      scale_x_continuous(
        labels = abs,
        limits = c(-fixed_max, fixed_max)   # << FIXED SCALE HERE
      ) +
      scale_y_discrete(
        drop = FALSE,
        limits = levels(fixed_age_levels),  # Use the fixed levels
        breaks = c(levels(fixed_age_levels)[1], levels(fixed_age_levels)[length(levels(fixed_age_levels))])  # Only show min and max
      ) +
      scale_fill_manual(values = sex_colors, breaks = sex_labels, drop = FALSE) +
      labs(
        x = "Count", y = "Age (years)",
        title = "",
        fill = "Sex"
      ) +
      theme_minimal(base_size = 15)
    
    
    # ------------------------------------------
    # CONVERT TO PLOTLY
    # ------------------------------------------
    p_ly <- ggplotly(p, tooltip = "text")
    
    # Fade legend entries for missing sexes
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