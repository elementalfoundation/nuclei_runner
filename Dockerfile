# We pin to a specific sha digest because those are immutable. We'll always get the same code.
FROM projectdiscovery/nuclei@sha256:aeb5ea2db32a252b8135707d2ad0e89b90e19a18ea7816d38759bc51efb46b97

# Optional: working dir for reports/output
WORKDIR /work

# Default command (can be overridden at runtime)
ENTRYPOINT ["nuclei"]
CMD ["-version"]   # default args if none are provided
