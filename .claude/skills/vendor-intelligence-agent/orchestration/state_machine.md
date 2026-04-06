# Agent State Machine

## States

### IDLE
- Agent is waiting for user input
- No tools loaded
- Minimal context in memory

**Transitions**:
- `on_user_request` → `GATHERING_DATA`

---

### GATHERING_DATA
- Agent has received user request
- Calling BigQuery to collect data
- Building working_memory with results

**Transitions**:
- `on_data_received` → `ANALYZING`
- `on_insufficient_data` → `RESEARCHING_DOCS`
- `on_error_retryable` → `GATHERING_DATA` (retry with different params)
- `on_error_fatal` → `IDLE` (escalate to user)

**Actions**:
- Calls vendor_analysis_skill (generates SQL)
- Executes via bigquery_query tool
- Stores results in context.working["last_query_results"]

---

### ANALYZING
- Agent has data, now interpreting it
- Applying analyst reasoning (hypothesis testing)
- Deciding next step

**Transitions**:
- `on_anomaly_detected` → `VISUALIZING`
- `on_needs_context` → `RESEARCHING_DOCS`
- `on_needs_peer_comparison` → `GATHERING_DATA`
- `on_complete` → `SYNTHESIZING`

**Actions**:
- Apply chain-of-thought to interpret metrics
- Flag anomalies (vs target, vs peers)
- Suggest hypotheses for root cause

---

### RESEARCHING_DOCS
- Agent is searching unstructured documents
- Looking for context, explanations, contract terms

**Transitions**:
- `on_docs_found` → `ANALYZING`
- `on_no_docs_found` → `SYNTHESIZING`
- `on_needs_more_query_data` → `GATHERING_DATA`

**Actions**:
- Calls document_search tool (multi-query)
- Extracts entities, key terms
- Stores insights in context.working["document_insights"]

---

### VISUALIZING
- Agent is creating dashboards or charts
- User asked for visuals or findings warrant visualization

**Transitions**:
- `on_dashboard_created` → `SYNTHESIZING`
- `on_looker_exists` → `SYNTHESIZING` (skip creation)

**Actions**:
- Check looker_explore tool for existing reports first
- If not found, call create_tableau_dashboard
- Stores dashboard URL in context.working["active_dashboards"]

---

### SYNTHESIZING
- Agent is preparing final response
- Combining all data/documents/visuals
- Writing plain-English interpretation

**Transitions**:
- `on_complete` → `COMPLETE`

**Actions**:
- Format summary
- Include all artifacts (SQL, data, dashboards, documents)
- Provide business recommendations

---

### COMPLETE
- Response ready for user
- All tools shut down
- Context preserved for follow-up

**Transitions**:
- `on_follow_up_question` → `GATHERING_DATA`
- `on_new_request` → `IDLE`

**Actions**:
- Clean up tool sessions
- Prune working_memory if context growing
- Keep persistent_context for continuity

---

## State Machine Diagram

```
┌─────────┐
│  IDLE   │
└────┬────┘
     │ on_user_request
     ▼
┌─────────────────┐
│ GATHERING_DATA  │◄─────────┐
└────┬────────────┘          │
     │ on_data_received       │ on_needs_query_data
     ▼                        │
┌─────────────────┐           │
│   ANALYZING     │───────────┘
└────┬────────────┘
     │
     ├─ on_anomaly_detected ──┐
     │                         ▼
     │                  ┌─────────────┐
     │                  │ VISUALIZING │
     │                  └──────┬──────┘
     │                         │ on_dashboard_created
     │                         │
     ├─ on_needs_context ──┐   │
     │                     ▼   │
     │            ┌──────────────────┐
     │            │ RESEARCHING_DOCS │
     │            └─────────┬────────┘
     │                      │ on_docs_found
     │                      └──────────┐
     │                                 │
     └─────────────┬────────────────────┘
                   │ on_complete
                   ▼
            ┌──────────────┐
            │ SYNTHESIZING │
            └─────┬────────┘
                  │ on_complete
                  ▼
            ┌──────────────┐
            │  COMPLETE    │
            └──────────────┘
```

---

## Context Management Across States

### IDLE
```yaml
persistent_context:
  current_vendor_id: null
  active_time_period: "last_12_months"
  user_role: "analyst"

working_memory: {}
external_memory: {}
```

### GATHERING_DATA
```yaml
persistent_context: [unchanged]

working_memory:
  last_query_results: [rows from BigQuery]
  query_cost: 0.15
  query_time: "2.3s"
```

### ANALYZING
```yaml
persistent_context:
  current_vendor_id: 12345  # Updated from query results
  
working_memory:
  last_query_results: [cached from GATHERING_DATA]
  hypotheses: ["H1: volume increase", "H2: price increase", ...]
  anomalies_detected: [list of metrics > thresholds]
```

### RESEARCHING_DOCS
```yaml
persistent_context: [unchanged]

working_memory:
  last_query_results: [cached]
  hypotheses: [cached]
  document_insights: [
    {document_type: "contract", title: "...", key_findings: ["...", "..."]}
  ]
  doc_search_cost: 0.50 (in tokens)
```

### VISUALIZING
```yaml
working_memory:
  last_query_results: [cached]
  active_dashboards: ["https://tableau.../vendor_analysis"]
  dashboard_cost: 0.25
```

### SYNTHESIZING
```yaml
working_memory:
  All above: [compressed summary]
  
final_response:
  sql_query: "..."
  interpretation: "..."
  documents_referenced: [...]
  dashboards_created: [...]
  recommendations: [...]
```

---

## Token Budget Tracking

```yaml
budget_per_request: 5000

tracking:
  GATHERING_DATA: 15 (base) + results
  ANALYZING: 0 (no tool use)
  RESEARCHING_DOCS: 30 (base) + doc costs (30/1000 pages)
  VISUALIZING: 25 (base) or 400 (update existing)
  SYNTHESIZING: 0 (no tool use)

example_workflow:
  1. GATHERING_DATA: 200 tokens (simple query)
  2. ANALYZING: 0 tokens
  3. RESEARCHING_DOCS: 500 tokens (100 docs searched)
  4. VISUALIZING: 400 tokens (update existing dashboard)
  5. SYNTHESIZING: 0 tokens
  ─────────────────────────
  TOTAL: 1,100 tokens (22% of budget, very efficient)
```

---

## Error Handling by State

### In GATHERING_DATA:
```yaml
error_type: "Query timeout"
action: "Narrow date range or vendor filter"
next_state: "GATHERING_DATA" (retry)
user_message: "Analyzing last 6 months instead of 12 for speed..."
```

### In RESEARCHING_DOCS:
```yaml
error_type: "Document index unavailable"
action: "Skip to next state without doc context"
next_state: "SYNTHESIZING"
user_message: "Document search unavailable; proceeding with query data only"
```

### In VISUALIZING:
```yaml
error_type: "Tableau auth failure"
action: "Fall back to static image or Looker"
next_state: "SYNTHESIZING"
user_message: "Dashboard update failed; showing Looker report instead"
```

### In ANALYZING:
```yaml
error_type: "Insufficient data (zero rows)"
action: "Suggest alternative filters"
next_state: "IDLE" or "GATHERING_DATA" (with user input)
user_message: "No results for that period. Try last quarter or remove the 'active' filter?"
```
