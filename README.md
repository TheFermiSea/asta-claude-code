# Asta for Claude Code

Two Claude Code skills for academic research via [Semantic Scholar](https://www.semanticscholar.org/) — powered by the [`asta` MCP server](https://github.com/allenai/asta) from Allen AI.

| Skill | Command | What it does |
|-------|---------|--------------|
| **asta-research** | `/asta-research` | Search 200M+ papers, follow citation trails, deep-dive key works |
| **asta-documents** | `/asta-documents` | Manage a local research library with smart search and `asta://` sharing |

---

## Why use this over searching Google Scholar manually?

- **Natural language queries** — ask "what papers cover deterministic quality gates in autonomous coding agents" and get ranked excerpts from paper *text*, not just title matches
- **Citation network traversal** — find a seminal paper, then pull everything that cites it in one call
- **Structured metadata** — every result includes TLDR, year, venue, citation count, and open-access status
- **Persistent library** — `asta-documents` tracks what you've found, tags it, and lets you share collections via portable `asta://` URIs
- **Composable** — pairs naturally with Gemini Deep Research (web breadth) and NotebookLM (persistent RAG)

---

## Quick Install

```bash
# Clone and run the installer
git clone https://github.com/TheFermiSea/asta-claude-code
cd asta-claude-code
bash install.sh
```

Or install just the skills without cloning:

```bash
bash install.sh --skills-only   # skills only (assumes asta MCP already configured)
bash install.sh --mcp-only      # MCP server only (no skill files)
```

---

## Full Setup

### 1. Install the Asta MCP server

```bash
uvx asta
```

Requires [uv](https://docs.astral.sh/uv/). The server runs locally and proxies to the Semantic Scholar API.

### 2. Register it in Claude Code

```bash
claude mcp add asta -- uvx asta
```

Or manually in `~/.claude/settings.json`:

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

### 3. Install the skills

```bash
cp -r skills/asta-research  ~/.claude/skills/
cp -r skills/asta-documents ~/.claude/skills/
```

After restarting Claude Code, `/asta-research` and `/asta-documents` are available.

---

## Adding Your Semantic Scholar Account

By default the `asta` MCP server uses the public Semantic Scholar API — no account needed, but rate-limited to ~100 requests/5 minutes.

For higher limits (1,000+ requests/minute and priority access), register a free API key:

1. **Request a key** at [semanticscholar.org/product/api](https://www.semanticscholar.org/product/api)
2. **Set the environment variable** before starting the server:

```bash
export SEMANTIC_SCHOLAR_API_KEY="your-key-here"
```

3. **Pass it to the MCP server** via your Claude Code settings:

```json
{
  "mcpServers": {
    "asta": {
      "command": "uvx",
      "args": ["asta"],
      "env": {
        "SEMANTIC_SCHOLAR_API_KEY": "your-key-here"
      }
    }
  }
}
```

> API keys are free for researchers and developers. The public tier is sufficient for occasional searches; the authenticated tier is worth setting up if you do frequent literature reviews.

---

## `/asta-research` — Academic Paper Search

### How it works

The skill runs a structured multi-step pipeline inside Claude Code:

```
1. snippet_search              → natural language → paper text excerpts
2. search_papers_by_relevance  → keyword → structured metadata with date range
3. get_paper                   → deep-dive the most relevant results
4. get_citations               → map the research frontier from seminal papers
5. Compile summary             → structured output, offer to save / import to NotebookLM
```

### Tool reference

| Tool | Purpose |
|------|---------|
| `snippet_search` | Natural language → paper text excerpts. **Start here.** |
| `search_papers_by_relevance` | Keyword search with date filtering and metadata |
| `get_paper` | Full paper: abstract, authors, references, citations |
| `search_paper_by_title` | Find a known paper by exact or partial title |
| `get_citations` | All papers that cite a given paper |
| `get_author_papers` | All papers from a known author ID |
| `search_authors_by_name` | Find an author's Semantic Scholar ID |
| `get_paper_batch` | Retrieve multiple papers at once by ID list |

### Writing effective queries

`snippet_search` searches paper *text* (abstracts, introductions, conclusions) — not just titles. Be specific:

```
# Good — specific enough to retrieve meaningful excerpts
"multi-agent coding systems with deterministic quality gates and compilation feedback"
"git worktree isolation for concurrent autonomous coding agents"
"mixture of experts model with expert layer CPU offloading for inference"
"speculative decoding with small draft model and large verifier"
"KV cache compression for long-context LLM inference"

# Too vague — will surface noise
"machine learning"   "LLMs"   "coding"   "AI systems"
```

### Date filtering

In `search_papers_by_relevance`, use `publication_date_range`:

```
"2024:"       → 2024 to present
"2023:2025"   → 2023 through 2025
":2022"       → up to 2022
```

### Paper ID formats

All four formats work with `get_paper` and `get_citations`:

```
Semantic Scholar ID  →  "649def34f8be52c8b66281af98ae884c09aef38b"
DOI                  →  "DOI:10.18653/v1/2023.acl-long.123"
arXiv                →  "ARXIV:2303.08774"
URL                  →  "URL:https://arxiv.org/abs/2303.08774"
```

### Output format

```markdown
# Academic Research: <Topic>

## Key Papers
1. **Title** (Year, Venue) — TLDR
   - URL: https://...
   - Citations: N | Open access: yes/no
   - Relevance: why this paper matters for the question

## Key Findings from Snippets
- Finding from paper text, attributed (Author et al., Year)

## Citation Network Insights
- Paper X (N citations) → field's current foundation
- Paper Y cites Z, bridging two previously separate lines of work

## Open Access Papers
- Direct links to freely readable PDFs
```

---

## `/asta-documents` — Research Library Management

A persistent local index for tracking papers, specs, and documents you've collected. Tag and annotate documents, search by content or metadata, fetch PDFs with local caching, and share collections via portable `asta://` URIs.

### Additional prerequisite

```bash
uv tool install git+https://github.com/allenai/asta-resource-repo.git
```

Verify: `asta-documents --help`

### Core operations

```bash
# Add a paper
asta-documents add https://arxiv.org/pdf/1706.03762.pdf \
  --name="Attention Is All You Need" \
  --summary="Seminal paper introducing Transformer architecture" \
  --tags="nlp,transformers,ai" \
  --extra='{"author": "Vaswani et al", "year": 2017, "venue": "NeurIPS"}'

# List and search
asta-documents list
asta-documents list --tags="transformers"
asta-documents search --summary="transformer attention mechanism"
asta-documents search --extra=".year > 2022"

# Fetch content (cached locally)
asta-documents fetch <uuid> -o /tmp/paper.pdf

# Update metadata
asta-documents update <uuid> --name="New Title" --tags="revised,2025"
```

### Multi-field search

```bash
# Intersection (default) — must match ALL conditions
asta-documents search --summary="transformers" --tags="ai"

# Union — match ANY condition
asta-documents search --summary="transformers" --name="BERT" --union

# Three fields: semantic ranking + metadata filters
asta-documents search --summary="attention mechanisms" \
  --tags="nlp" --extra=".year > 2020"
```

**Search ranking hierarchy:**
1. Summary (hybrid BM25 + semantic embeddings) — highest priority
2. Name (word-match ratio) — used when no summary query
3. Creation timestamp — fallback for tag/extra-only filters

### The `asta://` URI scheme

Documents in a shared index are addressable via `asta://` URIs, enabling portable research collections hosted on S3, GCS, or any HTTPS server:

```
asta://{url-encoded-index-url}/{uuid}
```

Example:
```
asta://https%3A%2F%2Fai.example.org%2Fpapers%2Findex.yaml/AbC123XyZ9
```

To access a shared collection:

```bash
# Parse, decode, download, browse
ASTA_URL="asta://https%3A%2F%2Fai.example.org%2Fpapers%2Findex.yaml/AbC123XyZ9"
ENCODED=$(echo "$ASTA_URL" | sed 's|^asta://||;s|/[^/]*$||')
UUID=$(echo "$ASTA_URL" | sed 's|.*/||')
INDEX_URL=$(python3 -c "import urllib.parse; print(urllib.parse.unquote('$ENCODED'))")

mkdir -p /tmp/asta-remote
curl -s -o /tmp/asta-remote/index.yaml "$INDEX_URL"

asta-documents list   --root /tmp/asta-remote
asta-documents search --summary="your query" --root /tmp/asta-remote
asta-documents fetch  "$UUID" --root /tmp/asta-remote -o /tmp/paper.pdf
```

Remote indexes are read-only. `--root` works with all read commands (list, search, get, fetch).

### Cloud storage

Documents can live on S3 or GCS, not just HTTPS:

```bash
# Add from S3
asta-documents add s3://my-bucket/papers/paper.pdf \
  --name="Internal Paper" --tags="proprietary"

# Add from GCS
asta-documents add gs://my-bucket/docs/spec.pdf --name="Spec"

# Fetch works identically for all protocols
asta-documents fetch <uuid> -o local-copy.pdf
```

Requires `aws` CLI (S3) or `gsutil` (GCS) with credentials configured.

### JSON output for scripting

Any command accepts `--json` for machine-readable output:

```bash
UUID=$(asta-documents search --summary="transformers" --json | \
  python3 -c "import sys,json; r=json.load(sys.stdin); print(r[0]['result']['uuid'] if r else '')")
asta-documents fetch "$UUID" -o result.pdf
```

### Cache management

```bash
asta-documents cache stats           # size + count
asta-documents cache list            # what's cached
asta-documents cache clean --days 7  # remove entries older than N days
asta-documents cache clear -y        # clear everything
```

---

## Troubleshooting

**`asta` MCP server not connecting**
- Run `uvx asta` once to warm the cache, then restart Claude Code
- Verify: `uvx asta --help`

**No results from `snippet_search`**
- Use 8–15 word natural language descriptions of the concept
- Avoid jargon that may not appear in paper text; try synonyms

**HTTP 429 (rate limited)**
- Wait 30s and retry; reduce `limit` parameter to 10
- Set a Semantic Scholar API key (see [Adding Your Semantic Scholar Account](#adding-your-semantic-scholar-account))

**Paper not found by ID**
- Try alternative formats: DOI, arXiv, URL
- Verify the paper exists at [semanticscholar.org](https://www.semanticscholar.org)

**`asta-documents: command not found`**
- `uv tool list | grep asta` — verify installation
- `export PATH="$HOME/.local/bin:$PATH"` — uv installs to this path

**`asta-documents` search returns nothing**
- `asta-documents list` — confirm documents exist
- Try simpler terms or `--union` when combining fields
- Use `--name="keyword"` for exact word matching

---

## Composing with other research tools

Asta covers the academic layer of a research workflow. It pairs well with:

- **Gemini Deep Research** — web-scale practitioner knowledge from 20–100+ sites. Run both in parallel for full coverage: Asta = peer-reviewed rigor, Gemini = real-world usage patterns.
- **NotebookLM** — import Asta search results into a persistent RAG knowledge base, queryable across future sessions without re-running searches.

---

## Links

- [Asta MCP server](https://github.com/allenai/asta) — Allen AI
- [asta-resource-repo](https://github.com/allenai/asta-resource-repo) — asta-documents CLI source
- [Semantic Scholar API](https://api.semanticscholar.org/) — 200M+ papers, 80M authors
- [Semantic Scholar API key signup](https://www.semanticscholar.org/product/api)
- [uv package manager](https://docs.astral.sh/uv/)
