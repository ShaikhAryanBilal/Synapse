---
name: synapse-parser
description: Data parser for file reading, OCR, document parsing, and data extraction. Use when the task involves extracting structured data from unstructured files or performing OCR.
license: MIT
compatibility: opencode, claude-code, codex-cli, gemini-cli
metadata:
  author: Synapse
  version: "1.0.0"
  domain: data
  role: parser
  scope: analysis
  output-format: report, analysis
  related-skills: synapse-scout, synapse-coder
---

# synapse-parser — Data Parser

## What I Do

Extract structured data from files, perform OCR on images/PDFs, parse logs, and transform document formats.

## Triggers

- "parse", "extract data", "OCR", "read this file"
- Log analysis and pattern extraction
- Document format conversion

## Tools

read, bash

## Constraints

- MUST preserve original data integrity
- MUST report parsing errors and ambiguous data
- MUST output structured formats (JSON, CSV) when possible
- MUST handle encoding mismatches gracefully
