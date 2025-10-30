```markdown
# XLMFISH — Litepaper (Draft)

Version: 2025-10-30  
Owner: @neocrex-xlmfish

## Summary
XLMFISH builds simple, trustworthy web experiences that help everyday users and businesses access Stellar — a fast, low‑cost payments network. We focus on clear UX, transparent operations, and auditable asset management so Web2 users can use tokens, liquidity, and basic decentralized finance without deep blockchain knowledge.

## Our Mission
Lower the barrier to Stellar by offering web-first tools and processes that feel familiar: clear dashboards, one‑click flows, and public evidence of important actions. We aim to increase real‑world usage of Stellar assets while maintaining strong operational controls and transparency.

## What We Build (for non‑technical users)
- A public dashboard that shows treasury and community wallet activity in plain terms.  
- Simple pages to view assets, liquidity and recent transactions with links to independent verifiers.  
- Guided, low‑risk flows for trial and production use (testnet dry‑runs before mainnet).  
- Documentation and templates so non‑developers (product teams, partners) can onboard safely.

## Non‑Custodial Principle
XLMFISH operates non‑custodially: we do not hold or control users' private keys or funds. Our tools and services help users interact with Stellar while they retain full ownership and control of their assets. For any service that requires signing, we provide clear guides for secure key management (hardware wallets, vaults, or offline signing) and never request or store secrets.

## Alignment with Stellar Principles
We design XLMFISH to follow Stellar best practices and SEPs. Key commitments:
- Host and maintain a compliant stellar.toml for recognized discovery (requires re-issue).  
- Follow SEP guidance for wallet and integration flows.  
- Use public, version‑controlled records for asset and wallet information to enable independent verification.

## Transparency & Security
- Canonical data (assets, wallets) are stored in versioned files and validated by CI; all important issuance and funding steps are recorded as audit artifacts.  
- Production keys follow strict operational rules: issuer keys are cold; distributor keys are used for day‑to‑day operations and secured in vaults or hardware. No secrets are stored in repositories.  
- Monitoring and alerts track treasury movements and bridge activity so issues are detected and addressed quickly.

## Cross‑Chain & Contracts (careful, phased approach)
We plan incremental interoperability (bridges, wrapped tokens) using proven patterns and external, audited components where appropriate. Soroban exploration is limited and audited before any production use.

## Roadmap (near term)
1. Publish user‑friendly demo flows and dashboards.  
2. Complete testnet dry‑runs with full audit artifacts.  
3. Deploy backend APIs that serve verified asset lists to frontends.  
4. Implement monitoring dashboards and alerting for treasury operations.  
5. Prepare multisig operational plan for mainnet.

## Governance & Collaboration
Verification of assets is community‑oriented: evidence is published, and owner signoff is required before marking assets as verified. We welcome feedback and collaboration from the Stellar Development Foundation and community partners to ensure standards, user safety, and interoperability.

## Get Involved
Review our public repos, try demo flows, and share feedback. Non‑developers can help with UX, outreach, and governance design; developers can contribute code, tests, and audit artifacts.

Contact: @neocrex-xlmfish — https://github.com/neocrex-xlmfish/stellar-assets
```
