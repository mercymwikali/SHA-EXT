# SHA Project High-Level Design (HLD)

Generated: 2026-08-06  
Project: SHA  
Platform: Microsoft Dynamics 365 Business Central AL Extension  
Application Version: 28.0.0.0  
Runtime: 17.0  
Target: Cloud  

## 1. Executive Summary

The SHA project is a Microsoft Dynamics 365 Business Central extension that integrates the Hospital-System application with external SHA APIs. It provides reusable AL client codeunits for patient eligibility, authorization, visits, claims, preauthorization, prescriptions, emergency claims, OTP handling, facility/professional lookup, terminology, and file upload/download flows.

The design centralizes HTTP communication, token management, error categorization, retry-on-authentication-failure, and integration audit logging. Functional service-specific codeunits build request payloads and call a shared SHA HTTP client, while setup and log pages expose configuration and operational visibility to users.

## 2. Scope

### In Scope

- SHA setup per Global Dimension 1 Code / branch.
- Secure storage of client secret and cached access tokens through Business Central Isolated Storage.
- OAuth-like token acquisition from `/api/v1/tenants/token`.
- Centralized JSON and multipart HTTP request handling.
- Integration logging with correlation ID, endpoint, method, timestamps, duration, HTTP status, error category, user, patient, appointment, consent token, request body, and response body.
- Service clients for eligibility, authorization, visits, claims, doctors, dispatch, preauth, prescriptions, emergency claims, OTP, patient search, facility search, professional search, interventions, and terminology.

### Out of Scope / Not Evident in Current Codebase

- Background job queue orchestration.
- User role/permission sets specific to the extension.
- Automated integration tests.
- UI pages for every service flow; current pages are setup, log, and client-secret dialog.
- SHA response persistence beyond the integration log.

## 3. System Context

```text
+-----------------------------+       +-----------------------------+
| Business Central Users       |       | AHS Hospital-System App      |
| Clinicians, Billing, Admins  |       | Patients, Appointments       |
+--------------+--------------+       +--------------+--------------+
               |                                     |
               v                                     v
        +------+-------------------------------------+------+
        |              SHA Business Central Extension       |
        | Setup, Auth, HTTP Client, Service Clients, Logs   |
        +------+-------------------------------------+------+
               | HTTPS JSON / multipart requests
               v
        +------+-------------------------------------+------+
        |                 External SHA API Platform          |
        | Tenants, Patients, Benefits, Claims, Uploads       |
        +----------------------------------------------------+
```

## 4. Architectural Overview

The extension follows a layered integration-client architecture.

```text
+-------------------------------------------------------------+
| Presentation Layer                                           |
| SHA Setup Page, SHA Integration Log Page, Client Secret Dialog|
+-----------------------------+-------------------------------+
                              |
                              v
+-------------------------------------------------------------+
| Service Client Layer                                         |
| Authorization, Visit, Eligibility, Claims, OTP, Preauth, etc. |
+-----------------------------+-------------------------------+
                              |
                              v
+-------------------------------------------------------------+
| Integration Infrastructure Layer                             |
| SHA Http Client, Authentication Management, Log Management    |
+-----------------------------+-------------------------------+
                              |
                              v
+-------------------------------------------------------------+
| Data / Configuration Layer                                   |
| SHA Setup, SHA Integration Log, Isolated Storage, Enums       |
+-------------------------------------------------------------+
```

## 5. Key Components

| Component | Type | Responsibility |
|---|---:|---|
| SHA Setup | Table 50001 | Stores branch-level SHA configuration: Global Dimension 1 Code, facility FR code, KMPDC registration number, environment, base URL, client ID, timeout, retry count, status, logging flag, enabled flag, and client secret state. |
| SHA Integration Log | Table 50000 | Stores operational audit entries for SHA API calls. Supports request/response body BLOB storage. |
| SHA Setup Page | Page 50002 | User-facing list page for SHA setup and client secret action. |
| SHA Integration Log Page | Page 50001 | User-facing log viewer with actions to view request and response bodies. |
| SHA Client Secret Dialog | Page 50000 | Standard dialog used to capture client secret securely. |
| SHA Authentication Mgt | Codeunit 50000 | Retrieves, refreshes, caches, and invalidates access tokens. Updates setup connection status. |
| SHA Http Client | Codeunit 50009 | Shared outbound HTTP client for JSON and multipart requests. Adds bearer token, timeout, retry on first 401, logging context, and error categorization. |
| SHA Integration Log Mgt | Codeunit 50010 | Creates SHA Integration Log entries after outbound calls. |
| Service Client Codeunits | Codeunits 50001-50018 | Domain-specific wrappers that build SHA request payloads/endpoints and call SHA Http Client. |
| SHA Enums | Enums 50000-50015 | Controlled values for service type, environment, ID types, regulators, error categories, document types, and workflow reasons. |

## 6. Service Client Capability Map

| Area | Codeunit | Main Capabilities |
|---|---|---|
| Authentication | SHA Authentication Mgt | Token retrieval, refresh, caching, connection status update. |
| Authorization | SHA Authorization Client | Create authorization using OTP or biometrics; get/reject authorization; parse guid/token/auth code. |
| Visit | SHA Visit Client | Create visit with OTP or authorization GUID; set effective coverage; parse consent token, visit number, invoice number, claim ID. |
| Eligibility & Benefits | SHA Eligibility Client | Check eligibility; benefits coverage; sub-benefits; interventions coverage; utilization balance; POMSF balance; bed occupancy. |
| Claims | SHA Claims Client | Add/remove diagnoses; add/edit/remove/resubmit claim lines; attachments; preview provider/payer claim; uploads; tariff resolution. |
| Claim Dispatch | SHA Claim Dispatch Client | Add next of kin; close claim; discharge inpatient; submit claim. |
| Claim Doctors | SHA Claim Doctors Client | Add/remove claim doctor. |
| Doctor Consent | SHA Doctor Consent Client | Request doctor consent for preauth, emergency claim, or prescription workflows. |
| Emergency | SHA Emergency Client | Get/add emergency protocols; create emergency claim; create EMT claim. |
| OTP | SHA OTP Client | Get patient contacts; send OTP; send discharge OTP; OTP whitelist callback; OTP whitelist request with file upload. |
| Patient | SHA Patient Client | Search patients and parse beneficiary client-registry ID. |
| Preauth | SHA Preauth Client | Fetch, create, cancel preauth; remove preauth doctors and attachments. |
| Prescription | SHA Prescription Client | Preview prescription; create prescription; create dispense; remove prescription doctor. |
| Professional | SHA Professional Client | Search professionals by ID, ID type, and regulator. |
| Facility | SHA Facility Client | Search facility by identifier or name. |
| Interventions | SHA Interventions Client | Add, restore, retire, and switch claim interventions. |
| Terminology | SHA Terminology Client | Search clinical concepts and mappings. |

## 7. Primary Runtime Flow

```text
1. Calling AL logic selects a branch / Global Dimension 1 Code.
2. Service client builds endpoint and JSON or multipart payload.
3. Service client calls SHA Http Client.
4. SHA Http Client loads SHA Setup and validates Enabled + Base URL.
5. SHA Http Client obtains bearer token from SHA Authentication Mgt.
6. Authentication manager returns cached token or requests a new token.
7. SHA Http Client sends HTTPS request to Base URL + relative endpoint.
8. On first HTTP 401, token is refreshed and request is retried once.
9. HTTP response body and status are returned to the caller.
10. SHA Integration Log Mgt records correlation ID, timing, status, error category, context, and optional request/response bodies.
```

## 8. Data Design

### SHA Setup

The setup table is keyed by `Global Dimension 1 Code`, allowing separate SHA configuration per branch, facility, or dimension value. Sensitive client secret material is not stored in the table directly. Instead, the table stores only whether the secret has been set, while the actual value is stored in Isolated Storage using a branch-specific key.

Important fields:

- Global Dimension 1 Code
- Facility FR Code
- KMPDC Registration No.
- Environment: Sandbox, UAT, Production
- Base URL
- Client ID
- Timeout (Sec)
- Retry Count
- Connection Status
- Last Successful Connection
- Last Error
- Log Request/Response Bodies
- Enabled
- Client Secret Set

### SHA Integration Log

The log table is keyed by auto-incrementing Entry No. and includes secondary keys for Correlation ID and Appointment No. It stores API metadata and optional payload bodies as BLOBs.

Important fields:

- Correlation ID
- Endpoint and Method
- Request Time, Response Time, Duration
- HTTP Status Code
- Error Category and Error Message
- Patient No. and Appointment No.
- Consent Token
- Global Dimension 1 Code
- User ID
- Request Body and Response Body

## 9. Security Design

- Client secrets are stored in Business Central Isolated Storage with company scope.
- Access tokens and token expiry values are cached in Isolated Storage using branch-specific keys.
- Access tokens are refreshed before expiry using a 60-second buffer.
- Requests include an `Authorization: Bearer <token>` header.
- A failed token or expired token scenario is handled by refreshing the token on the first HTTP 401 and retrying once.
- Request/response body logging is configurable because payloads may contain sensitive patient, claim, or clinical data.
- Setup records can be deleted, and deletion removes the corresponding stored client secret.

## 10. Integration Design

### Supported Payload Types

- JSON requests through `SendJson`.
- Multipart/form-data requests through `SendMultipart`.
- Multipart builder supports text fields and one optional file stream.

### Error Handling

The HTTP client categorizes responses as:

- 400: Validation
- 401: Authentication
- 403: Authorization
- 408: Timeout
- 409: Duplicate Request
- 500 and above: Server Error
- Other non-success statuses: Business Rule
- Transport failure: Network

### Observability

Every HTTP call is logged with a generated correlation ID. The log captures request/response timing, duration, endpoint, method, status, error category, and optional payload bodies. Context methods allow patient, appointment, and consent-token values to be associated with calls.

## 11. Deployment and Configuration

The extension is packaged as `Default Publisher_SHA_1.0.0.0.app` and targets Business Central Cloud.

Configuration steps:

1. Install/publish the SHA extension with dependency on `AHS Hospital-System` version `1.0.1.0`.
2. Open the SHA Setup page.
3. Create one setup row per Global Dimension 1 Code / branch.
4. Configure environment, base URL, facility FR code, KMPDC registration number, client ID, timeout, retry count, enabled flag, and body logging preference.
5. Use the Set Client Secret action to store the SHA client secret.
6. Run a controlled API call and verify Connection Status and SHA Integration Log output.

## 12. Dependencies

| Dependency | Publisher | Version |
|---|---|---|
| Hospital-System | AHS | 1.0.1.0 |

Referenced Business Central areas include Dimensions, Users, Temp Blob, Type Helper, HTTP client APIs, JSON APIs, and Isolated Storage.

## 13. Operational Considerations

- Enable request/response body logging only in controlled environments or when required for support, because payloads may contain sensitive clinical or patient information.
- Monitor failed integration logs by error category and HTTP status.
- Validate SHA Setup per branch before go-live.
- Review token failure and connection status after credential changes.
- Consider retention/archival rules for SHA Integration Log entries if volume grows.

## 14. Risks and Recommendations

| Risk / Gap | Impact | Recommendation |
|---|---|---|
| Retry Count setup field is present but current HTTP client behavior only retries once for first 401. | Operational expectation may differ from actual behavior. | Either implement configurable retry logic or rename/document the field as future-use. |
| Request/response body logs can contain sensitive data. | Privacy and compliance risk. | Keep body logging disabled by default in production and define retention rules. |
| No dedicated permission sets are evident. | Users may receive excessive or insufficient access. | Add permission sets for setup administrators and log viewers. |
| No automated tests are evident. | Regression risk across many endpoint wrappers. | Add AL test codeunits for payload construction, enum mapping, token refresh, and error categorization. |
| SHA response data is not persisted in domain tables. | Downstream operational visibility may rely on parsing responses manually. | Persist key external identifiers such as consent token, claim ID, authorization GUID, visit number, and invoice number where business workflows require them. |

## 15. Conclusion

The SHA extension is designed as a focused integration adapter between AHS Hospital-System and the SHA API platform. Its strongest architectural feature is centralization: authentication, outbound HTTP behavior, error classification, and logging are implemented once and reused across domain-specific service clients. The next design improvements should focus on configurable retry behavior, production-grade permissions, automated tests, and clear data-retention controls for integration logs.

