classPatterns = (
    ( SpgxRoadmapPdf,       '.*(\d{1})(qualify|quantify)_(.*)_(.*)_(spg.)_roadmaps(.*)(\+.*){0,1}\.pdf$' ),     # .*_ossbtmf_roadmap\.pdf
    ( OssBtmfRoadmapPdf,    '.*(\d{1})(qualify|quantify).*_ossbtmf_roadmap(\+.*){0,1}\.pdf$' ),                 # .*_ossbtmf_roadmap\.pdf
    ( PcssRoadmapPdf,       '.*(\d{1})(qualify|quantify).*_pcss_roadmaps(.*)(\+.*){0,1}\.pdf$' ),               #   .*_pcss_roadmaps.*\.pdf
    ( AncillaryPdf,         '.*(\d{1})(ancillary).*\.pdf$' ),                                                   #   .*_pcss_roadmaps.*\.pdf
)
