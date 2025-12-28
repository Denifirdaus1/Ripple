---
description: Perform deep online research on a specific topic using MCP tools
---

1.  **Clarify Research Goal**
    - Ask the user for the specific research question or topic if not already provided.
    - Confirm the depth required (Overview vs. Deep Technical Dive).

2.  **Initial Web Search**
    - Use the `search_web` tool to find relevant information.
    - If the scope is large, break it down into multiple specific search queries.

3.  **Analyze & Select Resources**
    - Review the search summaries.
    - Select the top 3-5 most promising URLs that seem to contain the detailed answer.
    - *Constraint*: Prioritize official documentation, reputable technical blogs, and active community discussions.

4.  **Deep Dive (Reading Content)**
    - For each selected URL:
        - Use `read_url_content` to extract the full text.
        - If `read_url_content` fails or the page is dynamic, use the `browser_subagent` to browse and extract information.

5.  **Synthesize & Report**
    - Create a comprehensive summary of the findings.
    - Structure:
        - **Summary**: Direct answer to the user's question.
        - **Key Details**: Deep dive into the mechanics/facts.
        - **Code/Examples**: Relevant snippets if applicable.
        - **References**: List of URLs with short descriptions.

6.  **Knowledge Capture (Optional)**
    - Ask the user if this research should be saved to the Agent-0.
    - If yes:
        - Propose creating a new Topic `current_research_topic` using `/create_topic`.
        - Or add as a Finding using `/create_finding`.
