# WPP Research

A collection of CLI scripts and SQL queries to research various WordPress performance aspects in the lab and in the field.

* The `cli` directory contains the source code for the various CLI scripts (which can be invoked by `npm run research`).
* The `sql` directory contains BigQuery SQL queries to gather field data from e.g. HTTP Archive.

## Fork

Additional features merged into this fork of [GoogleChromeLabs/wpp-research](https://github.com/GoogleChromeLabs/wpp-research):

* [Add TTLB (Time To Last Byte) metric](https://github.com/GoogleChromeLabs/wpp-research/pull/199)
* [Add --wait-until arg to benchmark-web-vitals](https://github.com/GoogleChromeLabs/wpp-research/pull/203)
