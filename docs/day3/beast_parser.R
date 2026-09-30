beast.parser <- function(template_file,
                         char,                 # named list: char[[taxon]] = vector of single-character states
                         ages,                 # data frame with columns `taxon` and `min_age`
                         out_file,
                         rate_times = NULL,    # optional numeric vector for skyline templates
                         seq_placeholder    = "%%SEQUENCES%%",
                         trait_placeholder  = "%%AGES%%",
                         root_placeholder   = "%%ROOT_TAXA%%",
                         nstates_placeholder = "%%NSTATES%%",
                         rate_placeholder   = "%%RATE_TIMES%%") {
  
  # --- checks -------------------------------------------------------------
  taxa <- names(char)
  if (is.null(taxa)) stop("`char` must be a named list.")
  if (!all(c("taxon", "min_age") %in% names(ages)))
    stop("`ages` needs columns `taxon` and `min_age`.")
  
  missing_ages <- setdiff(taxa, ages$taxon)
  extra_ages   <- setdiff(ages$taxon, taxa)
  if (length(missing_ages)) stop("No age for: ", paste(missing_ages, collapse = ", "))
  if (length(extra_ages))
    warning("Ages given for taxa without character data (ignored): ",
            paste(extra_ages, collapse = ", "))
  
  nchars <- lengths(char)
  if (length(unique(nchars)) != 1)
    stop("Taxa have different numbers of characters: ",
         paste(unique(nchars), collapse = ", "))
  aln_len <- nchars[[1]]
  
  # --- number of states (0/1 only -> 2; otherwise highest state + 1) ------
  all_states <- as.character(unlist(char, use.names = FALSE))
  observed   <- all_states[!is.na(all_states) & !all_states %in% c("?", "-")]
  if (!all(grepl("^[0-9]$", observed)))
    stop("Unexpected state symbols: ",
         paste(setdiff(unique(observed), as.character(0:9)), collapse = ", "))
  n_states <- max(2L, max(as.integer(observed)) + 1L)
  
  # --- sequence block -----------------------------------------------------
  seq_lines <- vapply(taxa, function(tx) {
    states <- as.character(char[[tx]])
    states[is.na(states)] <- "?"
    sprintf('<sequence id="seq_%s" spec="Sequence" taxon="%s" totalcount="%s" value="%s"/>',
            tx, tx, aln_len, paste(states, collapse = ""))
  }, character(1))
  seq_block <- paste(seq_lines, collapse = "\n")
  
  # --- trait (age) string -------------------------------------------------
  age_vals <- ages$min_age[match(taxa, ages$taxon)]
  age_str  <- paste0(taxa, "=",
                     format(age_vals, digits = 7, scientific = FALSE, trim = TRUE),
                     collapse = ",")
  
  # --- root-age MRCA prior taxa (all taxa) --------------------------------
  root_block <- paste(sprintf('<taxon id="%s" spec="Taxon"/>', sort(taxa)),
                      collapse = "\n")
  
  # --- fill template ------------------------------------------------------
  fills <- c(seq_block, age_str, root_block, as.character(n_states))
  names(fills) <- c(seq_placeholder, trait_placeholder,
                    root_placeholder, nstates_placeholder)
  
  if (!is.null(rate_times)) {
    if (!is.numeric(rate_times)) stop("`rate_times` must be a numeric vector.")
    fills[rate_placeholder] <- paste(format(rate_times, digits = 7,
                                            scientific = FALSE, trim = TRUE),
                                     collapse = " ")
  }
  
  tmpl <- paste(readLines(template_file, warn = FALSE), collapse = "\n")
  
  for (ph in names(fills)) {
    if (!grepl(ph, tmpl, fixed = TRUE))
      stop("Placeholder not found in template: ", ph)
    tmpl <- sub(ph, fills[[ph]], tmpl, fixed = TRUE)
  }
  
  if (is.null(rate_times) && grepl(rate_placeholder, tmpl, fixed = TRUE))
    warning("Template contains ", rate_placeholder, " but `rate_times` was not supplied.")
  
  writeLines(tmpl, out_file)
  invisible(list(sequences = seq_block, ages = age_str, root_taxa = root_block,
                 nrOfStates = n_states, rate_times = rate_times))
}
