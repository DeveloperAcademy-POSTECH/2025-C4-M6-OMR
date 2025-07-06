#!/bin/bash

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# ✅ 예외 커밋
if echo "$COMMIT_MSG" | grep -qE "^(Merge pull request|README\.md 업데이트)"; then
  exit 0
fi

# ✅ 제목 추출
TITLE=$(echo "$COMMIT_MSG" | head -n 1)

# ✅ 제목 정규식 검사 (이모지 optional, 공백 optional)
TITLE_REGEX="^(([[:graph:]]{1,3})\s*)?[A-Z][a-zA-Z]+\. .+"

if ! echo "$TITLE" | grep -Eq "$TITLE_REGEX"; then
  echo "❌ 제목 형식 오류:"
  echo "👉 제목은 'Type. 요약 설명' 또는 '📝 Type. 요약 설명' 형식이어야 합니다."
  exit 1
fi

# ✅ 제목 요약 길이 경고 (30자 이내 권장)
TITLE_SUMMARY=$(echo "$TITLE" | sed -E 's/^(([[:graph:]]{1,3})\s*)?[A-Z][a-zA-Z]+\.\s*//')
TITLE_LENGTH=$(echo -n "$TITLE_SUMMARY" | wc -m)

if [ "$TITLE_LENGTH" -gt 30 ]; then
  echo "⚠️ 제목 요약이 $TITLE_LENGTH자입니다 (30자 이내 권장)"
fi

# ✅ 본문 검사 (Why, How 필수)
if ! grep -q "^Why:" "$COMMIT_MSG_FILE" || \
   ! grep -q "^How:" "$COMMIT_MSG_FILE"; then
  echo "❌ 본문 누락: Why:, How: 섹션이 모두 포함되어야 합니다."
  exit 1
fi

exit 0