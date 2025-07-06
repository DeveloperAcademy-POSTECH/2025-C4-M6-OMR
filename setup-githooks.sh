#!/usr/bin/env bash
set -euo pipefail

echo "🔧 커밋 메시지 훅 설치 중..."

SRC="scripts/validate-commit-msg.sh"
DEST=".git/hooks/commit-msg"

# .git/hooks 경로 확인
if [ ! -d ".git/hooks" ]; then
  echo "❌ .git/hooks 디렉토리를 찾을 수 없습니다. git 저장소가 맞는지 확인해주세요."
  exit 1
fi

# 검사 스크립트 존재 확인
if [ ! -f "$SRC" ]; then
  echo "❌ $SRC 파일이 존재하지 않습니다."
  exit 1
fi

# 복사 및 실행 권한 부여
cp "$SRC" "$DEST"
chmod +x "$DEST"

echo "✅ 완료: .git/hooks/commit-msg 훅이 설치되었습니다."
echo "📌 커밋 메시지 규칙이 자동으로 적용됩니다."