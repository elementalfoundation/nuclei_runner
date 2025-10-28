# We pin to a specific sha digest because those are immutable. We'll always get the same code.
FROM projectdiscovery/nuclei@sha256:aeb5ea2db32a252b8135707d2ad0e89b90e19a18ea7816d38759bc51efb46b97

# Optional: working directory for reports
WORKDIR /scans
COPY targets/targets.txt /scans/

# Default command when you run "docker build -t nuclei_runner . && docker run nuclei_runner" (can be overridden at runtime)
# This is in so-called 'json form', instead of just writing 'ENTRYPOINT nuclei'.
# Apparently that makes a difference in how well it respond to stop signals and such.
ENTRYPOINT ["nuclei"] # the executable that is called when you run the above
CMD ["-version"]   # default arguments to that executable if none are provided
