# Asta — Claude Code Skill

Claude Code integration for [Asta](https://github.com/allenai/asta) — the Semantic Scholar MCP server by Allen AI. Search 200M+ peer-reviewed papers, arXiv preprints, and citation networks directly from your Claude Code session.

```
/asta-research "multi-agent systems with deterministic quality gates"
```

Returns structured results: key papers, abstracts, TLDRs, citation counts, and open-access links.

---

## What It Does

| Goal | Tool Used |
|------|-----------|
| Find papers by topic (natural language) | `snippet_search` |
| Discover papers by keyword | `search_papers_by_relevance` |
| Deep-dive a specific paper | `get_paper` |
| Find a known paper by title | `search_paper_by_title` |
| Follow citation trails | `get_citations` |
| Explore an author's work | `get_author_papers` / `search_authors_by_name` |
| Batch paper lookup | `get_paper_batch` |

---

## Setup

### 1. Install the Asta MCP Server

```bash
uvx asta
```

Requires [uv](https://docs.astral.sh/uv/). Asta provides the Semantic Scholar API as an MCP server with no API key needed.

### 2. Add Asta to Claude Code

In your Claude Code settings (`~/.claude/settings.json`):

```json
{
  "mcpServers": {
    "asta": {
      "command": "uvx",
      "args": ["asta"]
    }
  }
}
```

Or via CLI:

```bash
claude mcp add asta -- uvx asta
```

### 3. Install the Skill

```bash
# Copy skills/asta-research/ into your Claude Code skills directory
cp -r skills/asta-research ~/.claude/skills/

# For asta-documents (optional — local document index management)
cp asta-documents.md ~/.claude/skills/
```

---

## Usage

Once installed, invoke the skill from Claude Code:

```
/asta-research
```

Claude will prompt you for a research topic and execute a multi-step search:
1. **Snippet search** — natural language retrieval across paper text
2. **Keyword discovery** — structured metadata search with date filtering
3. **Deep-dive** — full paper details for the most relevant results
4. **Citation exploration** — follow research threads from seminal papers

### Output Format

```markdown
# Academic Research: <Topic>

## Key Papers
1. **Title** (Year, Venue) — TLDR
   - URL: https://...
   - Citations: N
   - Relevance: why this matters

## Key Findings from Snippets
- Finding with paper attribution

## Citation Network Insights
- Paper X cited by N papers → frontier direction

## Open Access Papers
- Direct links to freely readable PDFs
```

---

## Asta Documents (Optional)

`asta-documents.md` is a companion skill for managing a local document metadata index. Track papers, add tags, search your collection, and fetch PDFs.

Install the CLI:

```bash
uv tool install git+https://github.com/allenai/asta-resource-repo.git
```

Then invoke via Claude Code:

```
/asta-documents
```

---

## Tips

- **Start with `/asta-research`** — it runs snippet_search first (most powerful)
- **Use with Gemini Deep Research** — Asta gives academic rigor, Gemini gives practitioner breadth
- **Import results to NotebookLM** — the skill offers to save results for persistent querying
- **Date filtering** — use `publication_date_range="2024:"` to focus on recent work
- **Open access** — filter for `isOpenAccess=true` to get freely readable papers

---

## Related

- [Asta MCP Server](https://github.com/allenai/asta) — the underlying server by Allen AI
- [Semantic Scholar API](https://api.semanticscholar.org/) — 200M+ papers
- [deep-research-pipeline](https://github.com/TheFermiSea/deep-research-pipeline) — full pipeline combining Asta + Gemini + NotebookLM
