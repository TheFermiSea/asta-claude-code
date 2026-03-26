---
name: asta-research
description: >
  Search 200M+ peer-reviewed papers and arXiv preprints via Semantic Scholar.
  Use for literature review, finding academic evidence for claims, surveying
  a research area, following citation trails from seminal papers, or exploring
  an author's body of work. Returns structured results: titles, abstracts,
  TLDRs, venues, citation counts, and open-access links.
triggers:
  - "find papers on"
  - "what does the research say about"
  - "academic papers"
  - "literature review"
  - "cite some papers"
  - "what's been published on"
  - "arXiv"
  - "Semantic Scholar"
---

# Asta Academic Research

Search peer-reviewed papers and arXiv preprints via Semantic Scholar.

**Load tools first:**
```
ToolSearch("select:mcp__asta__search_papers_by_relevance,mcp__asta__snippet_search,mcp__asta__get_paper,mcp__asta__search_paper_by_title,mcp__asta__get_citations,mcp__asta__get_author_papers,mcp__asta__search_authors_by_name,mcp__asta__get_paper_batch")
```

---

## Tool Selection

| Goal | Tool | Notes |
|------|------|-------|
| Discover by concept | `snippet_search` | Natural language → paper text excerpts. **Start here.** |
| Discover by keyword | `search_papers_by_relevance` | Structured metadata, supports date range |
| Deep-dive a paper | `get_paper` | Full abstract, references, citations, authors |
| Find a known title | `search_paper_by_title` | Exact or partial title |
| Map what cites a paper | `get_citations` | Research frontier from a seminal work |
| Author's full output | `get_author_papers` | All papers from a known author ID |
| Find an author | `search_authors_by_name` | Returns author IDs for use in `get_author_papers` |
| Retrieve many at once | `get_paper_batch` | Bulk lookup by ID list |

---

## Step 1 — Snippet Search (always start here)

`snippet_search` searches paper *text*, not just titles. Use natural language:

```
mcp__asta__snippet_search(
  query="<describe the concept in 8-15 words>",
  limit=20
)
```

**Effective queries:**
```
"multi-agent coding systems with deterministic quality gates and compilation feedback"
"git worktree isolation for concurrent autonomous coding agents"
"mixture of experts model with expert layer CPU offloading"
"speculative decoding with small draft model and large verifier"
"KV cache compression for long-context LLM inference"
"reward modeling from human preference data RLHF"
```

**Ineffective queries (too vague):**
```
"machine learning"  "LLMs"  "coding"  "transformers"
```

---

## Step 2 — Keyword Paper Search

When you need structured metadata (venue, year, citation count) or date filtering:

```
mcp__asta__search_papers_by_relevance(
  keyword="<3-5 keywords>",
  fields="title,abstract,tldr,url,year,venue,isOpenAccess,citationCount",
  limit=20,
  publication_date_range="2023:"
)
```

**Date range format:**
- `"2024:"` — 2024 to present
- `"2023:2025"` — 2023 through 2025
- `":2022"` — up to and including 2022

**Useful field combinations:**
- Standard: `title,abstract,tldr,url,year,venue,isOpenAccess,citationCount`
- With authors: add `authors`
- With network: add `citations,references`

---

## Step 3 — Deep-Dive Key Papers

For the top 3-5 results from Steps 1-2:

```
mcp__asta__get_paper(
  paper_id="<id>",
  fields="title,abstract,tldr,url,year,venue,authors,citations,references,isOpenAccess,citationCount"
)
```

**Paper ID formats (all equivalent):**
```
Semantic Scholar ID  →  "649def34f8be52c8b66281af98ae884c09aef38b"
DOI                  →  "DOI:10.18653/v1/2023.acl-long.123"
arXiv                →  "ARXIV:2303.08774"
URL                  →  "URL:https://arxiv.org/abs/2303.08774"
```

---

## Step 4 — Follow Citation Trails

From a seminal paper, find everything that builds on it:

```
mcp__asta__get_citations(
  paper_id="<id>",
  fields="title,abstract,year,url,tldr,citationCount",
  limit=20
)
```

High citation counts on citing papers = the field's most important follow-up work. Low counts = frontier / recent work.

---

## Step 5 — Compile and Deliver

```markdown
# Academic Research: <Topic>

## Key Papers
1. **Title** (Year, Venue) — TLDR
   - URL: https://...
   - Citations: N | Open access: yes/no
   - Relevance: one sentence on why this matters

## Key Findings
- Finding from paper text, with attribution (Author et al., Year)

## Citation Network
- Paper X (N citations) → field's current foundation
- Paper Y cites Paper Z, bridging <domain A> and <domain B>

## Open Access Papers
- Direct PDF links where available
```

Offer to save results to a file or import into NotebookLM for persistent querying.

---

## Error Handling

| Problem | Fix |
|---------|-----|
| No snippet results | Broaden query; use more general language |
| No keyword results | Fewer keywords; remove date filter |
| HTTP 429 (rate limited) | Wait 30s; reduce `limit` to 10 |
| Paper not found by ID | Try DOI, arXiv, or URL format |
| TLDR field empty | Use `abstract` instead |
| Too many irrelevant results | Narrow with `publication_date_range` |

---

## Tips

- **snippet_search first, always** — finds matches no title search would surface
- **Combine**: snippet_search for discovery → get_paper for depth → get_citations for frontier
- **Open access filter**: add `"isOpenAccess": true` to skip paywalled results
- **Citation count as a signal**: >1000 = foundational; 10-100 = active recent work; <10 = very new or niche
- **Pair with Gemini Deep Research**: Asta = academic rigor; Gemini = practitioner breadth
