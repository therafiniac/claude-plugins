## 7. Server & Infrastructure

- [ ] The deployment target actually has a CDN/edge network for static
      content and (where supported) edge-rendered dynamic content close
      to users, rather than a single origin region serving a global
      audience.
- [ ] Server response compression (gzip/brotli) is enabled for
      text-based responses (HTML/CSS/JS/JSON).
- [ ] Cold-start latency is understood for serverless/function-based
      deployments — measure it, and know whether it materially affects
      real users (a rarely-hit admin route cold-starting is very
      different from a public homepage cold-starting).
- [ ] Health checks/monitoring exist for response time, not just uptime —
      a server that's "up" but responding slowly is still a real
      performance failure that should be visible.
- [ ] Auto-scaling (if applicable) is configured to actually respond to
      real traffic patterns, not left at a default that either
      over-provisions (wasted cost) or under-provisions (slow under load).

