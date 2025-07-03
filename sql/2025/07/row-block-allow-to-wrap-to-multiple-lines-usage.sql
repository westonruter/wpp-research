# HTTP Archive query to get % WordPress sites using Allow to wrap to multiple lines option in Row block.
#
# WPP Research, Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# See query results here: https://github.com/GoogleChromeLabs/wpp-research/pull/194

DECLARE
  DATE_TO_QUERY DATE DEFAULT '2025-07-01';

CREATE TEMPORARY FUNCTION IS_CMS(technologies ARRAY<STRUCT<technology STRING, categories ARRAY<STRING>, info ARRAY<STRING>>>, cms STRING, version STRING) RETURNS BOOL AS (
  EXISTS(
    SELECT * FROM UNNEST(technologies) AS technology, UNNEST(technology.info) AS info
    WHERE technology.technology = cms
    AND (
      version = ""
      OR ENDS_WITH(version, ".x") AND (STARTS_WITH(info, RTRIM(version, "x")) OR info = RTRIM(version, ".x"))
      OR info = version
    )
  )
);

WITH wordpress AS (
  SELECT
    client,
    page,
    BOOL(custom_metrics.cms.wordpress.block_theme) AS has_block_theme
  FROM
    `httparchive.crawl.pages`
  WHERE
    date = DATE_TO_QUERY
    AND IS_CMS(technologies, 'WordPress', '')
    AND is_root_page = TRUE
),

rowBlockDetection AS (
  SELECT
    client,
    page,
    TRUE AS has_row_block_use_wrap_option
  FROM
    `httparchive.crawl.requests`
  WHERE
    date = DATE_TO_QUERY
    AND is_root_page = TRUE
    AND is_main_document
    AND REGEXP_CONTAINS(response_body, r'<div class="wp-block-group is-horizontal is-nowrap')
)

SELECT
  client,
  COUNT(IF(has_row_block_use_wrap_option, page, NULL)) AS urls,
  COUNT(IF(has_block_theme, page, NULL)) AS block_theme,
  COUNT(page) AS total,
  COUNT(IF(has_row_block_use_wrap_option, page, NULL)) / COUNT(IF(has_block_theme, page, NULL)) AS pct_block_theme,
  COUNT(IF(has_row_block_use_wrap_option, page, NULL)) / COUNT(page) AS pct_total
FROM
  wordpress
LEFT JOIN
  rowBlockDetection
USING
  (client, page)
GROUP BY
  client
ORDER BY
  client
