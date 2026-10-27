# Scenario review scheduler

The FrontOffice Docker images include `cron`. At container startup, the
entrypoint installs and starts the Scenario review scheduler. By default it
runs daily at **02:15 UTC**:

```text
15 2 * * *
```

Configure it with these application-container environment variables:

| Variable | Default | Purpose |
| --- | --- | --- |
| `SCENARIO_REVIEW_SCHEDULER_ENABLED` | `true` | Set to `false` to omit the cron job. |
| `SCENARIO_REVIEW_SCHEDULER_CRON` | `15 2 * * *` | A five-field cron schedule, evaluated in UTC. |

The cron job calls the FrontOffice console command below. The command first
checks the final MONARC `scenario.enabled` configuration; when the Scenario
feature is disabled it exits successfully without querying or changing review
data. This lets one image be used safely for Scenario-enabled and legacy-only
installations.

For a non-Docker installation, schedule the same command with the host's cron
or scheduler:

```sh
cd /path/to/monarc
/usr/bin/php bin/console monarc:scenario-open-due-reviews
```

Schedule it at least daily. A more frequent schedule is safe: the command takes
the database advisory lock `scenario-review-schedule`, skips a concurrent run,
and persists one open scheduled case per analysis. Capture command output and
alert on a non-zero exit status; the output includes the number of cases opened
or notes that another invocation owns the lock.

The command only opens due review cases. It does not notify users, complete a
review, reset a periodic date, accept residual risk, or turn monitoring
evidence into a trigger occurrence. Those actions remain explicit, authorised
workflow steps in the Scenario workspace.

For local development, run `../scripts/validate-sra22-local.sh` from this
repository. It applies local migrations and invokes the command twice to check
registration and idempotency. Authenticated workflow validation must be run by
the operator or CI environment that owns its own session configuration.
