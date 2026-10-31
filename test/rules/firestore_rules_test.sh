#!/bin/bash
# Firestore security-rules regression suite (C2, C3, M11).
#
# Usage:
#   firebase emulators:exec --only firestore,auth \
#     "bash test/rules/firestore_rules_test.sh"
#
# Requires firebase-tools, curl and jq. The script talks to the emulator REST
# API directly, so the Flutter app does not need to be running.
set -u

PROJECT=aclub2
FS="http://127.0.0.1:8080/v1/projects/$PROJECT/databases/(default)/documents"
AUTH="http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key"

pass=0
fail=0
check() { # name expected actual
  if [ "$2" = "$3" ]; then
    echo "PASS: $1"
    pass=$((pass + 1))
  else
    echo "FAIL: $1 (expected $2, got $3)"
    fail=$((fail + 1))
  fi
}

signup() {
  curl -s -X POST "$AUTH" -H 'Content-Type: application/json' \
    -d "{\"email\":\"$1\",\"password\":\"password123\",\"returnSecureToken\":true}"
}

admin_patch() { # path json
  curl -s -o /dev/null -w '%{http_code}' -X PATCH "$FS/$1" \
    -H 'Authorization: Bearer owner' -H 'Content-Type: application/json' -d "$2"
}

user_patch() { # path json token
  curl -s -o /dev/null -w '%{http_code}' -X PATCH "$FS/$1" \
    -H "Authorization: Bearer $3" -H 'Content-Type: application/json' -d "$2"
}

U1=$(signup manager@test.com)
T1=$(echo "$U1" | jq -r .idToken)
ID1=$(echo "$U1" | jq -r .localId)
U2=$(signup member@test.com)
T2=$(echo "$U2" | jq -r .idToken)
ID2=$(echo "$U2" | jq -r .localId)
U3=$(signup leader@test.com)
T3=$(echo "$U3" | jq -r .idToken)
ID3=$(echo "$U3" | jq -r .localId)

# Seed section, members and events as admin.
admin_patch "sections/sec1" '{"fields":{"id":{"stringValue":"sec1"},"name":{"stringValue":"Sec 1"}}}' >/dev/null
admin_patch "sections/sec1/members/$ID1" "{\"fields\":{\"id\":{\"stringValue\":\"$ID1\"},\"userId\":{\"stringValue\":\"$ID1\"},\"sectionId\":{\"stringValue\":\"sec1\"},\"sectionRole\":{\"stringValue\":\"sectionManager\"}}}" >/dev/null
admin_patch "sections/sec1/members/$ID2" "{\"fields\":{\"id\":{\"stringValue\":\"$ID2\"},\"userId\":{\"stringValue\":\"$ID2\"},\"sectionId\":{\"stringValue\":\"sec1\"},\"sectionRole\":{\"stringValue\":\"member\"}}}" >/dev/null
admin_patch "sections/sec1/members/$ID3" "{\"fields\":{\"id\":{\"stringValue\":\"$ID3\"},\"userId\":{\"stringValue\":\"$ID3\"},\"sectionId\":{\"stringValue\":\"sec1\"},\"sectionRole\":{\"stringValue\":\"tripLeader\"}}}" >/dev/null

admin_patch "sections/sec1/events/evt-approval" '{"fields":{"id":{"stringValue":"evt-approval"},"sectionId":{"stringValue":"sec1"},"title":{"stringValue":"Approval Event"},"status":{"stringValue":"published"},"requiresApproval":{"booleanValue":true},"maxParticipants":{"integerValue":"10"},"creatorId":{"stringValue":"'$ID3'"},"tripLeaderIds":{"arrayValue":{"values":[{"stringValue":"'$ID3'"}]}}}}' >/dev/null
admin_patch "sections/sec1/events/evt-open" '{"fields":{"id":{"stringValue":"evt-open"},"sectionId":{"stringValue":"sec1"},"title":{"stringValue":"Open Event"},"status":{"stringValue":"published"},"requiresApproval":{"booleanValue":false},"maxParticipants":{"integerValue":"10"},"creatorId":{"stringValue":"'$ID3'"},"tripLeaderIds":{"arrayValue":{"values":[{"stringValue":"'$ID3'"}]}}}}' >/dev/null

TS='{"timestampValue":"2026-10-30T00:00:00Z"}'
reg() { # userId status extra_json
  local extra="${3:-}"
  echo "{\"fields\":{\"id\":{\"stringValue\":\"$1\"},\"userId\":{\"stringValue\":\"$1\"},\"status\":{\"stringValue\":\"$2\"},\"registeredAt\":$TS,\"updatedAt\":$TS$extra}}"
}

# 1. Self-approval on an approval-required event is denied.
R=$(user_patch "sections/sec1/events/evt-approval/registrations/$ID2" "$(reg "$ID2" approved)" "$T2")
check "member cannot self-approve (create)" 403 "$R"

# 2. Self-registration as pending is allowed.
R=$(user_patch "sections/sec1/events/evt-approval/registrations/$ID2" "$(reg "$ID2" pending)" "$T2")
check "member can create pending registration" 200 "$R"

# 3. Self-approval via update is denied.
R=$(user_patch "sections/sec1/events/evt-approval/registrations/$ID2" "$(reg "$ID2" approved)" "$T2")
check "member cannot self-approve (update)" 403 "$R"

# 4. Self-withdrawal is allowed.
R=$(user_patch "sections/sec1/events/evt-approval/registrations/$ID2" \
  "$(reg "$ID2" withdrawn ",\"withdrawnByUserId\":{\"stringValue\":\"$ID2\"},\"withdrawnAt\":$TS")" "$T2")
check "member can withdraw own registration" 200 "$R"

# 5. Re-registration after withdrawal is allowed.
R=$(user_patch "sections/sec1/events/evt-approval/registrations/$ID2" "$(reg "$ID2" pending)" "$T2")
check "member can re-register after withdrawal" 200 "$R"

# 6. Creating a registration under an arbitrary doc ID is denied.
R=$(user_patch "sections/sec1/events/evt-approval/registrations/other-id" "$(reg "$ID2" pending)" "$T2")
check "member cannot use arbitrary registration doc ID" 403 "$R"

# 7. A member cannot register another user.
R=$(user_patch "sections/sec1/events/evt-approval/registrations/$ID3" "$(reg "$ID3" pending)" "$T2")
check "member cannot register another user" 403 "$R"

# 8. Open event: self-registration as approved is allowed.
R=$(user_patch "sections/sec1/events/evt-open/registrations/$ID2" "$(reg "$ID2" approved)" "$T2")
check "member can self-register as approved on open event" 200 "$R"

# 9. A member cannot mark themselves attended.
R=$(user_patch "sections/sec1/events/evt-open/registrations/$ID2" "$(reg "$ID2" attended)" "$T2")
check "member cannot self-mark attended" 403 "$R"

# 10. A leader can approve a pending registration.
R=$(user_patch "sections/sec1/events/evt-approval/registrations/$ID2" "$(reg "$ID2" approved)" "$T3")
check "leader can approve a registration" 200 "$R"

# 11. A leader can register another member.
R=$(user_patch "sections/sec1/events/evt-open/registrations/$ID3" "$(reg "$ID3" approved)" "$T3")
check "leader can register another member" 200 "$R"

# 12. A member cannot hard-delete their own registration (soft delete only).
R=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE \
  "$FS/sections/sec1/events/evt-open/registrations/$ID2" -H "Authorization: Bearer $T2")
check "member cannot hard-delete own registration" 403 "$R"

# 13. A leader can hard-delete a registration.
R=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE \
  "$FS/sections/sec1/events/evt-open/registrations/$ID2" -H "Authorization: Bearer $T3")
check "leader can hard-delete a registration" 200 "$R"

# Seed a template as admin (owner token bypasses rules).
admin_patch "templates/t1" "{\"fields\":{\"id\":{\"stringValue\":\"t1\"},\"title\":{\"stringValue\":\"T\"},\"language\":{\"stringValue\":\"en\"},\"markdownText\":{\"stringValue\":\"x\"},\"createdBy\":{\"stringValue\":\"$ID1\"},\"createdAt\":$TS,\"updatedAt\":$TS}}" >/dev/null

# 14. A signed-in user can read templates.
R=$(curl -s -o /dev/null -w '%{http_code}' "$FS/templates/t1" -H "Authorization: Bearer $T2")
check "signed-in user can read templates" 200 "$R"

# 15. A signed-in non-admin cannot write templates.
R=$(user_patch "templates/t1" "{\"fields\":{\"id\":{\"stringValue\":\"t1\"},\"title\":{\"stringValue\":\"Hacked\"}}}" "$T2")
check "non-admin cannot write templates" 403 "$R"

# 16. An unauthenticated caller cannot write templates.
R=$(curl -s -o /dev/null -w '%{http_code}' -X PATCH "$FS/templates/t1" \
  -H 'Content-Type: application/json' -d '{"fields":{"title":{"stringValue":"Hacked"}}}')
check "unauthenticated cannot write templates" 403 "$R"

# ── C2: section membership ────────────────────────────────────────────────
U4=$(signup newcomer@test.com)
T4=$(echo "$U4" | jq -r .idToken)
ID4=$(echo "$U4" | jq -r .localId)

admin_patch "sections/sec2" '{"fields":{"id":{"stringValue":"sec2"},"name":{"stringValue":"Sec 2"}}}' >/dev/null
admin_patch "sections/sec3" '{"fields":{"id":{"stringValue":"sec3"},"name":{"stringValue":"Sec 3"}}}' >/dev/null

member_doc() { # docId sectionId role [externalSystemId]
  local external="${4:-}"
  if [ -n "$external" ]; then
    echo "{\"fields\":{\"id\":{\"stringValue\":\"$1\"},\"sectionId\":{\"stringValue\":\"$2\"},\"sectionRole\":{\"stringValue\":\"$3\"},\"externalSystemId\":{\"stringValue\":\"$external\"},\"joinedAt\":$TS}}"
  else
    echo "{\"fields\":{\"id\":{\"stringValue\":\"$1\"},\"sectionId\":{\"stringValue\":\"$2\"},\"sectionRole\":{\"stringValue\":\"$3\"},\"externalSystemId\":{\"nullValue\":null},\"joinedAt\":$TS}}"
  fi
}

# 17. A plain member cannot promote themselves.
R=$(user_patch "sections/sec1/members/$ID2" "$(member_doc "$ID2" sec1 sectionManager)" "$T2")
check "member cannot self-promote to sectionManager" 403 "$R"

# 18. A newcomer cannot self-join with a privileged role.
R=$(user_patch "sections/sec2/members/$ID4" "$(member_doc "$ID4" sec2 sectionManager)" "$T4")
check "newcomer cannot self-join as sectionManager" 403 "$R"

# 19. A newcomer can self-join an existing section as a plain member.
R=$(user_patch "sections/sec2/members/$ID4" "$(member_doc "$ID4" sec2 member)" "$T4")
check "newcomer can self-join as member" 200 "$R"

# 20. A member cannot promote themselves after joining.
R=$(user_patch "sections/sec2/members/$ID4" "$(member_doc "$ID4" sec2 tripLeader)" "$T4")
check "member cannot promote self after joining" 403 "$R"

# 21. A member cannot spoof the membership document id.
R=$(user_patch "sections/sec3/members/$ID4" "$(member_doc "someone-else" sec3 member)" "$T4")
check "member cannot spoof membership document id" 403 "$R"

# 22. A member cannot join a section that does not exist.
R=$(user_patch "sections/sec-missing/members/$ID4" "$(member_doc "$ID4" sec-missing member)" "$T4")
check "member cannot join nonexistent section" 403 "$R"

# 23. A member cannot claim an external membership id.
R=$(user_patch "sections/sec3/members/$ID4" "$(member_doc "$ID4" sec3 member ext-123)" "$T4")
check "member cannot claim external membership id" 403 "$R"

# 24. A member cannot create another user's membership.
R=$(user_patch "sections/sec3/members/$ID2" "$(member_doc "$ID2" sec3 member)" "$T4")
check "member cannot create another user's membership" 403 "$R"

# 25. A member cannot add extra fields to a self-join.
R=$(user_patch "sections/sec3/members/$ID4" "{\"fields\":{\"id\":{\"stringValue\":\"$ID4\"},\"sectionId\":{\"stringValue\":\"sec3\"},\"sectionRole\":{\"stringValue\":\"member\"},\"joinedAt\":$TS,\"isAdmin\":{\"booleanValue\":true}}}" "$T4")
check "member cannot add extra membership fields" 403 "$R"

# 26. A member can leave their own section.
R=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE "$FS/sections/sec2/members/$ID4" -H "Authorization: Bearer $T4")
check "member can leave their own section" 200 "$R"

# 27. A member cannot delete someone else's membership.
R=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE "$FS/sections/sec1/members/$ID2" -H "Authorization: Bearer $T4")
check "member cannot delete another membership" 403 "$R"

# 28. A section manager can change a member's role.
R=$(user_patch "sections/sec1/members/$ID2" "$(member_doc "$ID2" sec1 tripLeader)" "$T1")
check "section manager can change a member role" 200 "$R"

echo "----"
echo "passed=$pass failed=$fail"
[ "$fail" -eq 0 ]
