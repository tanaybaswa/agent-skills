# Azure reference architectures

Diagrams and editable sources from the
[Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/browse/),
filtered to **Azure Container Apps**.

## Included

### Deploy microservices to Azure Container Apps

An existing Kubernetes workload (Fabrikam's fictional drone-delivery app)
replatformed from AKS onto Container Apps. One Container Apps environment hosts
five microservices — ingestion, workflow, package, drone scheduler, delivery —
with Service Bus for async messaging, three separate state stores, and Azure
Monitor for observability.

| File | Format |
| --- | --- |
| `microservices-with-container-apps.svg` | Vector diagram (the published source, not a screenshot) |
| `microservices-with-container-apps.vsdx` | Editable Visio source |

Article: https://learn.microsoft.com/en-us/azure/architecture/example-scenario/serverless/microservices-with-container-apps

Services used: Container Apps, Container Registry, Azure Cosmos DB, Azure
DocumentDB, Service Bus, Azure Managed Redis, Key Vault, Azure Monitor,
Application Insights, Log Analytics.

### Deploy microservices with Azure Container Apps and Dapr

The greenfield counterpart — a fictional "Red Dog" order management system on a
single Container Apps environment hosting 10 .NET microservices with Dapr
handling state, pub/sub, and service invocation.

| File | Format |
| --- | --- |
| `microservices-with-container-apps-dapr.png` | Diagram (no Visio source published) |

Article: https://learn.microsoft.com/en-us/azure/architecture/example-scenario/serverless/microservices-with-container-apps-dapr

## Attribution

These diagrams come from Microsoft Learn's Azure Architecture Center, licensed
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

> © Microsoft Corporation. Sourced from the Azure Architecture Center
> (https://learn.microsoft.com/en-us/azure/architecture/), licensed under
> Creative Commons Attribution 4.0 International.

Retrieved 2026-08-25. Keep this attribution with the files if you redistribute
them, and note any modifications you make.

Note: the Azure **icons** in `../icons/` are under different, more restrictive
terms than these diagrams — see [`../README.md`](../README.md).
