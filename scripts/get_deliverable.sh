# ./get_deliverable.sh <token> <anr_id> <model_id>
clear
echo "======"
echo http://monarcfo/api/client-anr/$2/deliverable?model=$3
echo "======"

curl -H "Token: $1" http://monarcfo/api/client-anr/$2/deliverable?model=$3 > /tmp/exported.docx 2>/dev/null

if grep "errors" /tmp/exported.docx; then
	cat /tmp/exported.docx
fi

echo ""
