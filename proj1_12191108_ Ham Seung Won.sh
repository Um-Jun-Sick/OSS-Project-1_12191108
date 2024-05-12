#!/bin/bash

# 파일 인자 3개 받는지 확인 / 아니면 사용법 출력
if [ $# -ne 3 ]; then
    echo "usage: ./proj1_12191108_ Ham Seung Won.sh file1 file2 file3"
    exit 1
fi

# 파일의 이름에 따라 팀파일, 플레이어 파일, 매치 파일 변수에 넣기
for arg in "$1" "$2" "$3"; do
    if [[ "$arg" == *"team"* ]]; then
        team_file="$arg"
    elif [[ "$arg" == *"players"* ]]; then
        players_file="$arg"
    elif [[ "$arg" == *"matches"* ]]; then
        matches_file="$arg"
    fi
done


# 자신의 학번과 이름 출력하기
echo "************OSS1 - Project1************"
echo "*     StudentID : 12191108            *"
echo "*     Name : SEUNGWON HAM             *"
echo "***************************************"

echo ""
echo ""

# 메뉴 출력 후 입력 받고 case문으로 선택하기 

while true; do
    echo "[MENU]"
    echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
    echo "2. Get the team data to enter a league position in teams.csv"
    echo "3. Get the Top-3 Attendance matches in matches.csv"
    echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
    echo "5. Get the modified format of date_GMT in matches.csv"
    echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
    echo "7. Exit"

    # 사용자로부터 입력 받기
    read -p "Enter your CHOICE(1~7): " choice

    # case문 사용
    case "$choice" in



        1)
        read -p "Do you want to get the Heung-Min Son's data? (y/n): " answer
        if [ "$answer" = "y" ]; then
            cat $players_file | awk -F, '$1 ~ /Heung/ {print "Team:" $4 ", Apperance:" $6 ", Goal:" $7 ", Assist:" $8}'

        elif [ "$answer" = "n" ]; then
            echo "continue.."
	    echo ""
            continue
        else
            echo "Invalid response. Please enter 'y' or 'n'."
        fi
        ;;



	2)
        read -p "What do you want to get the team data of league_position[1~20] : " answer
        if [ "$answer" -ge 1 ] && [ "$answer" -le 20 ]; then
            cat $team_file | awk -F, -v ans="$answer" '$6 == ans {print $6 " " $1 " " ($2/($2+$3+$4))}'
        else
            echo "Invalid league position. Please enter a number between 1 and 20."
            echo ""
            continue
        fi
        ;;



        3)
        read -p "Do you want to know Top-3 attendance data and average attendance? (y/n) : " answer
	if [ "$answer" = "y" ]; then
		echo "***Top-3 Attendance Match***"
		echo " "
		cat $matches_file | sort -t, -k2,2nr | head -n 3 | awk -F, '{print $3 " vs " $4 " (" $1 ")\n" $2 " " $7 "\n"}'
        elif [ "$answer" = "n" ]; then
            echo "continue.."
            echo ""
            continue
        else
            echo "Invalid response. Please enter 'y' or 'n'."
        fi
        ;;



        4)
         # 사용자로부터 입력 받기
	read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n): " answer
	if [ "$answer" = "y" ]; then
    		# 팀 파일에서 리그 포지션으로 정렬하고 팀 이름만 추출하여 배열에 저장
    		IFS=$'\n' read -d '' -r -a sorted_teams < <(tail -n +2 "$team_file" | sort -t, -k6,6n | cut -d, -f1)

    		# 배열을 통해 각 팀 이름 출력 및 각 팀의 최고 득점 선수 출력
		rank=1
    		for team in "${sorted_teams[@]}"; do
        		echo ""
			echo "$rank  $team"
        		# 해당 팀의 최고 득점 선수 찾기
	    		awk -F, -v team="$team" '$4 == team {print $1 "," $7}' "$players_file" | sort -t',' -k2,2nr | head -n 1 | awk -F, '{print $1 " " $2}'
			((rank++))
		done


	elif [ "$answer" = "n" ]; then
    		echo "Continuing without displaying team rankings or top scorers."
    		# 필요한 경우 다른 작업을 여기에 추가
	else
    		echo "Invalid response. Please enter 'y' or 'n'."
    		# 잘못된 입력 처리
	fi
	;;
	
       
        5)
	read -p "Do you want to modify the format of date? (y/n) : " answer
        if [ "$answer" = "y" ]; then
	# matches_file에서 데이터를 읽고, 1행을 제외한 나머지 행을 처리
	tail -n +2 "$matches_file" | \
	sed -E 's/^([A-Za-z]+) ([0-9]+) ([0-9]+) - ([0-9]+:[0-9]+)(am|pm),.*/\1 \2 \3 \4\5/' | \
	awk '{
    	# 월을 숫자로 변환
    	split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", month, " ");
    	for (i=1; i<=12; i++) m[month[i]] = i;

    	# 출력 형식 설정
    	split($1, arr, " ");
    	printf("%s/%02d/%02d %s\n", $3, m[$1], $2, $4);
	}' | head -n 10


        elif [ "$answer" = "n" ]; then
                echo "Continue..."
                # 필요한 경우 다른 작업을 여기에 추가
        else
                echo "Invalid response. Please enter 'y' or 'n'."
                # 잘못된 입력 처리
        fi
        ;;


        6)
        #teams_file에서 팀 이름만 읽어서 배열에 저장
	IFS=$'\n' read -r -d '' -a teams < <(tail -n +2 "$team_file" | cut -d, -f1 && printf '\0')

	# 배열의 내용을 두 열로 출력하여 팀 목록 보여주기
	half_index=$((${#teams[@]} / 2))  # 배열 길이의 절반을 계산
	for ((i=0; i<half_index; i++)); do
    		left_team="${teams[i]}"
    		right_team="${teams[i+half_index]}"
    		printf "%2d) %-25s %2d) %s\n" $((i + 1)) "$left_team" $((i + 1 + half_index)) "$right_team"
	done

	# 사용자 입력을 받아 해당 팀의 정보 처리
	read -p "Enter your team number: " team_number
	selected_team="${teams[team_number-1]}"
	echo ""


	# 홈 경기 승점차 계산 및 출력
	awk -F, -v team="$selected_team" '
    	$3 == team {
        margin = $5 - $6;
        if (margin > max_margin) {
            max_margin = margin;
            max_records = $1 "\n" team " " $5 " vs " $6 " " $4;
        } else if (margin == max_margin) {
            max_records = max_records "\n\n" $1 "\n" team " " $5 " vs " $6 " " $4;
        }
    	}
    	END { print max_records }' "$matches_file"
        ;;
        7)
            echo "Bye!"
            break
            ;;
        *)
            echo "Invalid choice, please enter a number between 1 and 7."
            ;;
    esac
    echo ""
done

