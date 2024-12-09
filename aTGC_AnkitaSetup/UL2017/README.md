- Check for failed jobs, 21 November 2024 at 18:53

```bash
condor_q 16414998
grep -rn "Failed to open the file.*Mini" logs/log_1641*.stdout
```
