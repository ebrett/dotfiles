# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
VCS_INFO_formats () {
	setopt localoptions noksharrays NO_shwordsplit
	local msg tmp
	local -i i
	local -A hook_com
	hook_com=(action "$1" action_orig "$1" branch "$2" branch_orig "$2" base "$3" base_orig "$3" staged "$4" staged_orig "$4" unstaged "$5" unstaged_orig "$5" revision "$6" revision_orig "$6" misc "$7" misc_orig "$7" vcs "${vcs}" vcs_orig "${vcs}") 
	hook_com[base-name]="${${hook_com[base]}:t}" 
	hook_com[base-name_orig]="${hook_com[base-name]}" 
	hook_com[subdir]="$(VCS_INFO_reposub ${hook_com[base]})" 
	hook_com[subdir_orig]="${hook_com[subdir]}" 
	: vcs_info-patch-9b9840f2-91e5-4471-af84-9e9a0dc68c1b
	for tmp in base base-name branch misc revision subdir
	do
		hook_com[$tmp]="${hook_com[$tmp]//\%/%%}" 
	done
	VCS_INFO_hook 'post-backend'
	if [[ -n ${hook_com[action]} ]]
	then
		zstyle -a ":vcs_info:${vcs}:${usercontext}:${rrn}" actionformats msgs
		(( ${#msgs} < 1 )) && msgs[1]=' (%s)-[%b|%a]%u%c-' 
	else
		zstyle -a ":vcs_info:${vcs}:${usercontext}:${rrn}" formats msgs
		(( ${#msgs} < 1 )) && msgs[1]=' (%s)-[%b]%u%c-' 
	fi
	if [[ -n ${hook_com[staged]} ]]
	then
		zstyle -s ":vcs_info:${vcs}:${usercontext}:${rrn}" stagedstr tmp
		[[ -z ${tmp} ]] && hook_com[staged]='S'  || hook_com[staged]=${tmp} 
	fi
	if [[ -n ${hook_com[unstaged]} ]]
	then
		zstyle -s ":vcs_info:${vcs}:${usercontext}:${rrn}" unstagedstr tmp
		[[ -z ${tmp} ]] && hook_com[unstaged]='U'  || hook_com[unstaged]=${tmp} 
	fi
	if [[ ${quiltmode} != 'standalone' ]] && VCS_INFO_hook "pre-addon-quilt"
	then
		local REPLY
		VCS_INFO_quilt addon
		hook_com[quilt]="${REPLY}" 
		unset REPLY
	elif [[ ${quiltmode} == 'standalone' ]]
	then
		hook_com[quilt]=${hook_com[misc]} 
	fi
	(( ${#msgs} > maxexports )) && msgs[$(( maxexports + 1 )),-1]=() 
	for i in {1..${#msgs}}
	do
		if VCS_INFO_hook "set-message" $(( $i - 1 )) "${msgs[$i]}"
		then
			zformat -f msg ${msgs[$i]} a:${hook_com[action]} b:${hook_com[branch]} c:${hook_com[staged]} i:${hook_com[revision]} m:${hook_com[misc]} r:${hook_com[base-name]} s:${hook_com[vcs]} u:${hook_com[unstaged]} Q:${hook_com[quilt]} R:${hook_com[base]} S:${hook_com[subdir]}
			msgs[$i]=${msg} 
		else
			msgs[$i]=${hook_com[message]} 
		fi
	done
	hook_com=() 
	backend_misc=() 
	return 0
}
add-zle-hook-widget () {
	# undefined
	builtin autoload -XU
}
add-zsh-hook () {
	emulate -L zsh
	local -a hooktypes
	hooktypes=(chpwd precmd preexec periodic zshaddhistory zshexit zsh_directory_name) 
	local usage="Usage: add-zsh-hook hook function\nValid hooks are:\n  $hooktypes" 
	local opt
	local -a autoopts
	integer del list help
	while getopts "dDhLUzk" opt
	do
		case $opt in
			(d) del=1  ;;
			(D) del=2  ;;
			(h) help=1  ;;
			(L) list=1  ;;
			([Uzk]) autoopts+=(-$opt)  ;;
			(*) return 1 ;;
		esac
	done
	shift $(( OPTIND - 1 ))
	if (( list ))
	then
		typeset -mp "(${1:-${(@j:|:)hooktypes}})_functions"
		return $?
	elif (( help || $# != 2 || ${hooktypes[(I)$1]} == 0 ))
	then
		print -u$(( 2 - help )) $usage
		return $(( 1 - help ))
	fi
	local hook="${1}_functions" 
	local fn="$2" 
	if (( del ))
	then
		if (( ${(P)+hook} ))
		then
			if (( del == 2 ))
			then
				set -A $hook ${(P)hook:#${~fn}}
			else
				set -A $hook ${(P)hook:#$fn}
			fi
			if (( ! ${(P)#hook} ))
			then
				unset $hook
			fi
		fi
	else
		if (( ${(P)+hook} ))
		then
			if (( ${${(P)hook}[(I)$fn]} == 0 ))
			then
				typeset -ga $hook
				set -A $hook ${(P)hook} $fn
			fi
		else
			typeset -ga $hook
			set -A $hook $fn
		fi
		autoload $autoopts -- $fn
	fi
}
add_api_key () {
	local service_name="$1" 
	local env_var_name="${service_name}_API_KEY" 
	env_var_name=$(echo "$env_var_name" | tr '[:lower:]' '[:upper:]') 
	if [[ -n "${API_KEYS[$env_var_name]}" ]]
	then
		echo "API key for $service_name already exists as $env_var_name"
		return 0
	fi
	echo "Adding new API key definition for $service_name"
	local op_path="op://Developer/${service_name} API Key/credential" 
	API_KEYS[$env_var_name]="$op_path" 
	echo "Added $env_var_name with 1Password path: $op_path"
	echo "You can now load it with: load_api_key $env_var_name"
	return 0
}
alias_value () {
	(( $+aliases[$1] )) && echo $aliases[$1]
}
azure_prompt_info () {
	return 1
}
bashcompinit () {
	# undefined
	builtin autoload -XUz
}
bracketed-paste-magic () {
	# undefined
	builtin autoload -XUz
}
brews () {
	local formulae="$(brew leaves | xargs brew deps --installed --for-each)" 
	local casks="$(brew list --cask 2>/dev/null)" 
	local blue="$(tput setaf 4)" 
	local bold="$(tput bold)" 
	local off="$(tput sgr0)" 
	echo "${blue}==>${off} ${bold}Formulae${off}"
	echo "${formulae}" | sed "s/^\(.*\):\(.*\)$/\1${blue}\2${off}/"
	echo "\n${blue}==>${off} ${bold}Casks${off}\n${casks}"
}
btrestart () {
	sudo kextunload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
	sudo kextload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
}
bundle_install () {
	if (( ! $+commands[bundle] ))
	then
		echo "Bundler is not installed"
		return 1
	fi
	if ! _within-bundled-project
	then
		echo "Can't 'bundle install' outside a bundled project"
		return 1
	fi
	autoload -Uz is-at-least
	local bundler_version=$(bundle version | cut -d' ' -f3) 
	if ! is-at-least 1.4.0 "$bundler_version"
	then
		bundle install "$@"
		return $?
	fi
	if [[ "$OSTYPE" = (darwin|freebsd)* ]]
	then
		local cores_num="$(sysctl -n hw.ncpu)" 
	else
		local cores_num="$(nproc)" 
	fi
	BUNDLE_JOBS="$cores_num" bundle install "$@"
}
bundled_annotate () {
	_run-with-bundler "annotate" "$@"
}
bundled_cap () {
	_run-with-bundler "cap" "$@"
}
bundled_capify () {
	_run-with-bundler "capify" "$@"
}
bundled_cucumber () {
	_run-with-bundler "cucumber" "$@"
}
bundled_foodcritic () {
	_run-with-bundler "foodcritic" "$@"
}
bundled_guard () {
	_run-with-bundler "guard" "$@"
}
bundled_hanami () {
	_run-with-bundler "hanami" "$@"
}
bundled_irb () {
	_run-with-bundler "irb" "$@"
}
bundled_jekyll () {
	_run-with-bundler "jekyll" "$@"
}
bundled_kitchen () {
	_run-with-bundler "kitchen" "$@"
}
bundled_knife () {
	_run-with-bundler "knife" "$@"
}
bundled_middleman () {
	_run-with-bundler "middleman" "$@"
}
bundled_nanoc () {
	_run-with-bundler "nanoc" "$@"
}
bundled_pry () {
	_run-with-bundler "pry" "$@"
}
bundled_puma () {
	_run-with-bundler "puma" "$@"
}
bundled_rackup () {
	_run-with-bundler "rackup" "$@"
}
bundled_rainbows () {
	_run-with-bundler "rainbows" "$@"
}
bundled_rake () {
	_run-with-bundler "rake" "$@"
}
bundled_rspec () {
	_run-with-bundler "rspec" "$@"
}
bundled_rubocop () {
	_run-with-bundler "rubocop" "$@"
}
bundled_shotgun () {
	_run-with-bundler "shotgun" "$@"
}
bundled_sidekiq () {
	_run-with-bundler "sidekiq" "$@"
}
bundled_spec () {
	_run-with-bundler "spec" "$@"
}
bundled_spork () {
	_run-with-bundler "spork" "$@"
}
bundled_spring () {
	_run-with-bundler "spring" "$@"
}
bundled_strainer () {
	_run-with-bundler "strainer" "$@"
}
bundled_tailor () {
	_run-with-bundler "tailor" "$@"
}
bundled_taps () {
	_run-with-bundler "taps" "$@"
}
bundled_thin () {
	_run-with-bundler "thin" "$@"
}
bundled_thor () {
	_run-with-bundler "thor" "$@"
}
bundled_unicorn () {
	_run-with-bundler "unicorn" "$@"
}
bundled_unicorn_rails () {
	_run-with-bundler "unicorn_rails" "$@"
}
bzr_prompt_info () {
	local bzr_branch
	bzr_branch=$(bzr nick 2>/dev/null)  || return
	if [[ -n "$bzr_branch" ]]
	then
		local bzr_dirty="" 
		if [[ -n $(bzr status 2>/dev/null) ]]
		then
			bzr_dirty=" %{$fg[red]%}*%{$reset_color%}" 
		fi
		printf "%s%s%s%s" "$ZSH_THEME_SCM_PROMPT_PREFIX" "bzr::${bzr_branch##*:}" "$bzr_dirty" "$ZSH_THEME_GIT_PROMPT_SUFFIX"
	fi
}
cdf () {
	cd "$(pfd)"
}
cdx () {
	cd "$(pxd)"
}
check_op_cli () {
	if ! command -v op &> /dev/null
	then
		echo "Error: 1Password CLI (op) is not installed"
		echo "Please install it from https://1password.com/downloads/command-line/"
		return 1
	fi
	return 0
}
chruby_prompt_info () {
	return 1
}
clipcopy () {
	unfunction clipcopy clippaste
	detect-clipboard || true
	"$0" "$@"
}
clippaste () {
	unfunction clipcopy clippaste
	detect-clipboard || true
	"$0" "$@"
}
colored () {
	local -a environment
	local k v
	for k v in "${(@kv)less_termcap}"
	do
		environment+=("LESS_TERMCAP_${k}=${v}") 
	done
	environment+=(PAGER="${commands[less]:-$PAGER}") 
	environment+=(GROFF_NO_SGR=1) 
	if [[ "$OSTYPE" = solaris* ]]
	then
		environment+=(PATH="${__colored_man_pages_dir}:$PATH") 
	fi
	command env $environment "$@"
}
colorize_cat () {
	if ! colorize_check_requirements
	then
		return 1
	fi
	if [ -z "$ZSH_COLORIZE_STYLE" ]
	then
		ZSH_COLORIZE_STYLE="emacs" 
	fi
	if [ ! -t 0 ]
	then
		if [[ "$ZSH_COLORIZE_TOOL" == "pygmentize" ]]
		then
			pygmentize -O style="$ZSH_COLORIZE_STYLE" -g
		else
			chroma --style="$ZSH_COLORIZE_STYLE" --formatter="${ZSH_COLORIZE_CHROMA_FORMATTER:-terminal}" "$@"
		fi
		return $?
	fi
	local FNAME lexer
	for FNAME in "$@"
	do
		if [[ "$ZSH_COLORIZE_TOOL" == "pygmentize" ]]
		then
			lexer=$(pygmentize -N "$FNAME") 
			if [[ $lexer != text ]]
			then
				pygmentize -O style="$ZSH_COLORIZE_STYLE" -l "$lexer" "$FNAME"
			else
				pygmentize -O style="$ZSH_COLORIZE_STYLE" -g "$FNAME"
			fi
		else
			chroma --style="$ZSH_COLORIZE_STYLE" --formatter="${ZSH_COLORIZE_CHROMA_FORMATTER:-terminal}" "$FNAME"
		fi
	done
}
colorize_check_requirements () {
	local -a available_tools
	available_tools=("chroma" "pygmentize") 
	if [ -z "$ZSH_COLORIZE_TOOL" ]
	then
		if (( $+commands[pygmentize] ))
		then
			ZSH_COLORIZE_TOOL="pygmentize" 
		elif (( $+commands[chroma] ))
		then
			ZSH_COLORIZE_TOOL="chroma" 
		else
			echo "Neither 'pygments' nor 'chroma' is installed!" >&2
			return 1
		fi
	fi
	if [[ ${available_tools[(Ie)$ZSH_COLORIZE_TOOL]} -eq 0 ]]
	then
		echo "ZSH_COLORIZE_TOOL '$ZSH_COLORIZE_TOOL' not recognized. Available options are 'pygmentize' and 'chroma'." >&2
		return 1
	elif ! (( $+commands[$ZSH_COLORIZE_TOOL] ))
	then
		echo "Package '$ZSH_COLORIZE_TOOL' is not installed!" >&2
		return 1
	fi
}
colorize_less () {
	if ! colorize_check_requirements
	then
		return 1
	fi
	_cless () {
		local LESS="-R $LESS" 
		local LESSOPEN="| zsh -c 'source \"$ZSH_COLORIZE_PLUGIN_PATH\";         ZSH_COLORIZE_TOOL=$ZSH_COLORIZE_TOOL ZSH_COLORIZE_STYLE=$ZSH_COLORIZE_STYLE         colorize_cat %s 2> /dev/null'" 
		local LESSCLOSE="" 
		LESS="$LESS" LESSOPEN="$LESSOPEN" LESSCLOSE="$LESSCLOSE" command less "$@"
	}
	if [ -t 0 ]
	then
		_cless "$@"
	else
		colorize_cat | _cless "$@"
	fi
}
colors () {
	emulate -L zsh
	typeset -Ag color colour
	color=(00 none 01 bold 02 faint 22 normal 03 italic 23 no-italic 04 underline 24 no-underline 05 blink 25 no-blink 07 reverse 27 no-reverse 08 conceal 28 no-conceal 30 black 40 bg-black 31 red 41 bg-red 32 green 42 bg-green 33 yellow 43 bg-yellow 34 blue 44 bg-blue 35 magenta 45 bg-magenta 36 cyan 46 bg-cyan 37 white 47 bg-white 39 default 49 bg-default) 
	local k
	for k in ${(k)color}
	do
		color[${color[$k]}]=$k 
	done
	for k in ${color[(I)3?]}
	do
		color[fg-${color[$k]}]=$k 
	done
	for k in grey gray
	do
		color[$k]=${color[black]} 
		color[fg-$k]=${color[$k]} 
		color[bg-$k]=${color[bg-black]} 
	done
	colour=(${(kv)color}) 
	local lc=$'\e[' rc=m 
	typeset -Hg reset_color bold_color
	reset_color="$lc${color[none]}$rc" 
	bold_color="$lc${color[bold]}$rc" 
	typeset -AHg fg fg_bold fg_no_bold
	for k in ${(k)color[(I)fg-*]}
	do
		fg[${k#fg-}]="$lc${color[$k]}$rc" 
		fg_bold[${k#fg-}]="$lc${color[bold]};${color[$k]}$rc" 
		fg_no_bold[${k#fg-}]="$lc${color[normal]};${color[$k]}$rc" 
	done
	typeset -AHg bg bg_bold bg_no_bold
	for k in ${(k)color[(I)bg-*]}
	do
		bg[${k#bg-}]="$lc${color[$k]}$rc" 
		bg_bold[${k#bg-}]="$lc${color[bold]};${color[$k]}$rc" 
		bg_no_bold[${k#bg-}]="$lc${color[normal]};${color[$k]}$rc" 
	done
}
command_not_found_handler () {
	if [[ "$1" != "mise" && "$1" != "mise-"* ]] && /opt/homebrew/bin/mise hook-not-found -s zsh -- "$1"
	then
		_mise_hook
		"$@"
	elif [ -n "$(declare -f _command_not_found_handler)" ]
	then
		_command_not_found_handler "$@"
	else
		echo "zsh: command not found: $1" >&2
		return 127
	fi
}
compaudit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compdef () {
	local opt autol type func delete eval new i ret=0 cmd svc 
	local -a match mbegin mend
	emulate -L zsh
	setopt extendedglob
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	while getopts "anpPkKde" opt
	do
		case "$opt" in
			(a) autol=yes  ;;
			(n) new=yes  ;;
			([pPkK]) if [[ -n "$type" ]]
				then
					print -u2 "$0: type already set to $type"
					return 1
				fi
				if [[ "$opt" = p ]]
				then
					type=pattern 
				elif [[ "$opt" = P ]]
				then
					type=postpattern 
				elif [[ "$opt" = K ]]
				then
					type=widgetkey 
				else
					type=key 
				fi ;;
			(d) delete=yes  ;;
			(e) eval=yes  ;;
		esac
	done
	shift OPTIND-1
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	if [[ -z "$delete" ]]
	then
		if [[ -z "$eval" ]] && [[ "$1" = *\=* ]]
		then
			while (( $# ))
			do
				if [[ "$1" = *\=* ]]
				then
					cmd="${1%%\=*}" 
					svc="${1#*\=}" 
					func="$_comps[${_services[(r)$svc]:-$svc}]" 
					[[ -n ${_services[$svc]} ]] && svc=${_services[$svc]} 
					[[ -z "$func" ]] && func="${${_patcomps[(K)$svc][1]}:-${_postpatcomps[(K)$svc][1]}}" 
					if [[ -n "$func" ]]
					then
						_comps[$cmd]="$func" 
						_services[$cmd]="$svc" 
					else
						print -u2 "$0: unknown command or service: $svc"
						ret=1 
					fi
				else
					print -u2 "$0: invalid argument: $1"
					ret=1 
				fi
				shift
			done
			return ret
		fi
		func="$1" 
		[[ -n "$autol" ]] && autoload -rUz "$func"
		shift
		case "$type" in
			(widgetkey) while [[ -n $1 ]]
				do
					if [[ $# -lt 3 ]]
					then
						print -u2 "$0: compdef -K requires <widget> <comp-widget> <key>"
						return 1
					fi
					[[ $1 = _* ]] || 1="_$1" 
					[[ $2 = .* ]] || 2=".$2" 
					[[ $2 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$1" "$2" "$func"
					if [[ -n $new ]]
					then
						bindkey "$3" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] && bindkey "$3" "$1"
					else
						bindkey "$3" "$1"
					fi
					shift 3
				done ;;
			(key) if [[ $# -lt 2 ]]
				then
					print -u2 "$0: missing keys"
					return 1
				fi
				if [[ $1 = .* ]]
				then
					[[ $1 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" "$1" "$func"
				else
					[[ $1 = menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" ".$1" "$func"
				fi
				shift
				for i
				do
					if [[ -n $new ]]
					then
						bindkey "$i" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] || continue
					fi
					bindkey "$i" "$func"
				done ;;
			(*) while (( $# ))
				do
					if [[ "$1" = -N ]]
					then
						type=normal 
					elif [[ "$1" = -p ]]
					then
						type=pattern 
					elif [[ "$1" = -P ]]
					then
						type=postpattern 
					else
						case "$type" in
							(pattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_patcomps[$match[1]]="=$match[2]=$func" 
								else
									_patcomps[$1]="$func" 
								fi ;;
							(postpattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_postpatcomps[$match[1]]="=$match[2]=$func" 
								else
									_postpatcomps[$1]="$func" 
								fi ;;
							(*) if [[ "$1" = *\=* ]]
								then
									cmd="${1%%\=*}" 
									svc=yes 
								else
									cmd="$1" 
									svc= 
								fi
								if [[ -z "$new" || -z "${_comps[$1]}" ]]
								then
									_comps[$cmd]="$func" 
									[[ -n "$svc" ]] && _services[$cmd]="${1#*\=}" 
								fi ;;
						esac
					fi
					shift
				done ;;
		esac
	else
		case "$type" in
			(pattern) unset "_patcomps[$^@]" ;;
			(postpattern) unset "_postpatcomps[$^@]" ;;
			(key) print -u2 "$0: cannot restore key bindings"
				return 1 ;;
			(*) unset "_comps[$^@]" ;;
		esac
	fi
}
compdump () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compgen () {
	local opts prefix suffix job OPTARG OPTIND ret=1 
	local -a name res results jids
	local -A shortopts
	emulate -L sh
	setopt kshglob noshglob braceexpand nokshautoload
	shortopts=(a alias b builtin c command d directory e export f file g group j job k keyword u user v variable) 
	while getopts "o:A:G:C:F:P:S:W:X:abcdefgjkuv" name
	do
		case $name in
			([abcdefgjkuv]) OPTARG="${shortopts[$name]}"  ;&
			(A) case $OPTARG in
					(alias) results+=("${(k)aliases[@]}")  ;;
					(arrayvar) results+=("${(k@)parameters[(R)array*]}")  ;;
					(binding) results+=("${(k)widgets[@]}")  ;;
					(builtin) results+=("${(k)builtins[@]}" "${(k)dis_builtins[@]}")  ;;
					(command) results+=("${(k)commands[@]}" "${(k)aliases[@]}" "${(k)builtins[@]}" "${(k)functions[@]}" "${(k)reswords[@]}")  ;;
					(directory) setopt bareglobqual
						results+=(${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N-/)) 
						setopt nobareglobqual ;;
					(disabled) results+=("${(k)dis_builtins[@]}")  ;;
					(enabled) results+=("${(k)builtins[@]}")  ;;
					(export) results+=("${(k)parameters[(R)*export*]}")  ;;
					(file) setopt bareglobqual
						results+=(${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N)) 
						setopt nobareglobqual ;;
					(function) results+=("${(k)functions[@]}")  ;;
					(group) emulate zsh
						_groups -U -O res
						emulate sh
						setopt kshglob noshglob braceexpand
						results+=("${res[@]}")  ;;
					(hostname) emulate zsh
						_hosts -U -O res
						emulate sh
						setopt kshglob noshglob braceexpand
						results+=("${res[@]}")  ;;
					(job) results+=("${savejobtexts[@]%% *}")  ;;
					(keyword) results+=("${(k)reswords[@]}")  ;;
					(running) jids=("${(@k)savejobstates[(R)running*]}") 
						for job in "${jids[@]}"
						do
							results+=(${savejobtexts[$job]%% *}) 
						done ;;
					(stopped) jids=("${(@k)savejobstates[(R)suspended*]}") 
						for job in "${jids[@]}"
						do
							results+=(${savejobtexts[$job]%% *}) 
						done ;;
					(setopt | shopt) results+=("${(k)options[@]}")  ;;
					(signal) results+=("SIG${^signals[@]}")  ;;
					(user) results+=("${(k)userdirs[@]}")  ;;
					(variable) results+=("${(k)parameters[@]}")  ;;
					(helptopic)  ;;
				esac ;;
			(F) COMPREPLY=() 
				local -a args
				args=("${words[0]}" "${@[-1]}" "${words[CURRENT-2]}") 
				() {
					typeset -h words
					$OPTARG "${args[@]}"
				}
				results+=("${COMPREPLY[@]}")  ;;
			(G) setopt nullglob
				results+=(${~OPTARG}) 
				unsetopt nullglob ;;
			(W) results+=(${(Q)~=OPTARG})  ;;
			(C) results+=($(eval $OPTARG))  ;;
			(P) prefix="$OPTARG"  ;;
			(S) suffix="$OPTARG"  ;;
			(X) if [[ ${OPTARG[0]} = '!' ]]
				then
					results=("${(M)results[@]:#${OPTARG#?}}") 
				else
					results=("${results[@]:#$OPTARG}") 
				fi ;;
		esac
	done
	print -l -r -- "$prefix${^results[@]}$suffix"
}
compinit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compinstall () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
complete () {
	emulate -L zsh
	local args void cmd print remove
	args=("$@") 
	zparseopts -D -a void o: A: G: W: C: F: P: S: X: a b c d e f g j k u v p=print r=remove
	if [[ -n $print ]]
	then
		printf 'complete %2$s %1$s\n' "${(@kv)_comps[(R)_bash*]#* }"
	elif [[ -n $remove ]]
	then
		for cmd
		do
			unset "_comps[$cmd]"
		done
	else
		compdef _bash_complete\ ${(j. .)${(q)args[1,-1-$#]}} "$@"
	fi
}
conda_prompt_info () {
	return 1
}
current_branch () {
	git_current_branch
}
d () {
	if [[ -n $1 ]]
	then
		dirs "$@"
	else
		dirs -v | head -n 10
	fi
}
debman () {
	colored $0 "$@"
}
default () {
	(( $+parameters[$1] )) && return 0
	typeset -g "$1"="$2" && return 3
}
detect-clipboard () {
	emulate -L zsh
	if [[ "${OSTYPE}" == darwin* ]] && (( ${+commands[pbcopy]} )) && (( ${+commands[pbpaste]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | pbcopy
		}
		clippaste () {
			pbpaste
		}
	elif [[ "${OSTYPE}" == (cygwin|msys)* ]]
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" > /dev/clipboard
		}
		clippaste () {
			cat /dev/clipboard
		}
	elif (( $+commands[clip.exe] )) && (( $+commands[powershell.exe] ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | clip.exe
		}
		clippaste () {
			powershell.exe -noprofile -command Get-Clipboard
		}
	elif [ -n "${WAYLAND_DISPLAY:-}" ] && (( ${+commands[wl-copy]} )) && (( ${+commands[wl-paste]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | wl-copy &> /dev/null &|
		}
		clippaste () {
			wl-paste --no-newline
		}
	elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xsel]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | xsel --clipboard --input
		}
		clippaste () {
			xsel --clipboard --output
		}
	elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xclip]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | xclip -selection clipboard -in &> /dev/null &|
		}
		clippaste () {
			xclip -out -selection clipboard
		}
	elif (( ${+commands[lemonade]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | lemonade copy
		}
		clippaste () {
			lemonade paste
		}
	elif (( ${+commands[doitclient]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | doitclient wclip
		}
		clippaste () {
			doitclient wclip -r
		}
	elif (( ${+commands[win32yank]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | win32yank -i
		}
		clippaste () {
			win32yank -o
		}
	elif [[ $OSTYPE == linux-android* ]] && (( $+commands[termux-clipboard-set] ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | termux-clipboard-set
		}
		clippaste () {
			termux-clipboard-get
		}
	elif [ -n "${TMUX:-}" ] && (( ${+commands[tmux]} ))
	then
		clipcopy () {
			tmux load-buffer "${1:--}"
		}
		clippaste () {
			tmux save-buffer -
		}
	else
		_retry_clipboard_detection_or_fail () {
			local clipcmd="${1}" 
			shift
			if detect-clipboard
			then
				"${clipcmd}" "$@"
			else
				print "${clipcmd}: Platform $OSTYPE not supported or xclip/xsel not installed" >&2
				return 1
			fi
		}
		clipcopy () {
			_retry_clipboard_detection_or_fail clipcopy "$@"
		}
		clippaste () {
			_retry_clipboard_detection_or_fail clippaste "$@"
		}
		return 1
	fi
}
diff () {
	command diff --color "$@"
}
dman () {
	colored $0 "$@"
}
down-line-or-beginning-search () {
	# undefined
	builtin autoload -XU
}
edit-command-line () {
	# undefined
	builtin autoload -XU
}
ensure_op_signin () {
	if ! op whoami &> /dev/null
	then
		echo "Not logged into 1Password. Attempting to sign in..."
		if ! op signin
		then
			echo "Failed to sign in to 1Password CLI"
			return 1
		fi
		echo "Successfully signed in to 1Password"
	fi
	return 0
}
env_default () {
	[[ ${parameters[$1]} = *-export* ]] && return 0
	export "$1=$2" && return 3
}
expand-or-complete-with-dots () {
	[[ $COMPLETION_WAITING_DOTS = true ]] && COMPLETION_WAITING_DOTS="%F{red}…%f" 
	printf '\e[?7l%s\e[?7h' "${(%)COMPLETION_WAITING_DOTS}"
	zle expand-or-complete
	zle redisplay
}
freespace () {
	if [[ -z "$1" ]]
	then
		echo "Usage: $0 <disk>"
		echo "Example: $0 /dev/disk1s1"
		echo
		echo "Possible disks:"
		df -h | awk 'NR == 1 || /^\/dev\/disk/'
		return 1
	fi
	echo "Cleaning purgeable files from disk: $1 ...."
	diskutil secureErase freespace 0 $1
}
gbda () {
	git branch --no-color --merged | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" | command xargs git branch --delete 2> /dev/null
}
gbds () {
	local default_branch=$(git_main_branch) 
	(( ! $? )) || default_branch=$(git_develop_branch) 
	git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch
	do
		local merge_base=$(git merge-base $default_branch $branch) 
		if [[ $(git cherry $default_branch $(git commit-tree $(git rev-parse $branch\^{tree}) -p $merge_base -m _)) = -* ]]
		then
			git branch -D $branch
		fi
	done
}
gccd () {
	setopt localoptions extendedglob
	local repo="${${@[(r)(ssh://*|git://*|ftp(s)#://*|http(s)#://*|*@*)(.git/#)#]}:-$_}" 
	command git clone --recurse-submodules "$@" || return
	[[ -d "$_" ]] && cd "$_" || cd "${${repo:t}%.git/#}"
}
gdnolock () {
	git diff "$@" ":(exclude)package-lock.json" ":(exclude)*.lock"
}
gdv () {
	git diff -w "$@" | view -
}
getent () {
	if [[ $1 = hosts ]]
	then
		sed 's/#.*//' /etc/$1 | grep -w $2
	elif [[ $2 = <-> ]]
	then
		grep ":$2:[^:]*$" /etc/$1
	else
		grep "^$2:" /etc/$1
	fi
}
ggf () {
	[[ "$#" != 1 ]] && local b="$(git_current_branch)" 
	git push --force origin "${b:=$1}"
}
ggfl () {
	[[ "$#" != 1 ]] && local b="$(git_current_branch)" 
	git push --force-with-lease origin "${b:=$1}"
}
ggl () {
	if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]
	then
		git pull origin "${*}"
	else
		[[ "$#" == 0 ]] && local b="$(git_current_branch)" 
		git pull origin "${b:=$1}"
	fi
}
ggp () {
	if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]
	then
		git push origin "${*}"
	else
		[[ "$#" == 0 ]] && local b="$(git_current_branch)" 
		git push origin "${b:=$1}"
	fi
}
ggpnp () {
	if [[ "$#" == 0 ]]
	then
		ggl && ggp
	else
		ggl "${*}" && ggp "${*}"
	fi
}
ggu () {
	[[ "$#" != 1 ]] && local b="$(git_current_branch)" 
	git pull --rebase origin "${b:=$1}"
}
git_commits_ahead () {
	if __git_prompt_git rev-parse --git-dir &> /dev/null
	then
		local commits="$(__git_prompt_git rev-list --count @{upstream}..HEAD 2>/dev/null)" 
		if [[ -n "$commits" && "$commits" != 0 ]]
		then
			echo "$ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX$commits$ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX"
		fi
	fi
}
git_commits_behind () {
	if __git_prompt_git rev-parse --git-dir &> /dev/null
	then
		local commits="$(__git_prompt_git rev-list --count HEAD..@{upstream} 2>/dev/null)" 
		if [[ -n "$commits" && "$commits" != 0 ]]
		then
			echo "$ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX$commits$ZSH_THEME_GIT_COMMITS_BEHIND_SUFFIX"
		fi
	fi
}
git_current_branch () {
	local ref
	ref=$(__git_prompt_git symbolic-ref --quiet HEAD 2> /dev/null) 
	local ret=$? 
	if [[ $ret != 0 ]]
	then
		[[ $ret == 128 ]] && return
		ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null)  || return
	fi
	echo ${ref#refs/heads/}
}
git_current_user_email () {
	__git_prompt_git config user.email 2> /dev/null
}
git_current_user_name () {
	__git_prompt_git config user.name 2> /dev/null
}
git_develop_branch () {
	command git rev-parse --git-dir &> /dev/null || return
	local branch
	for branch in dev devel develop development
	do
		if command git show-ref -q --verify refs/heads/$branch
		then
			echo $branch
			return 0
		fi
	done
	echo develop
	return 1
}
git_main_branch () {
	command git rev-parse --git-dir &> /dev/null || return
	local ref
	for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}
	do
		if command git show-ref -q --verify $ref
		then
			echo ${ref:t}
			return 0
		fi
	done
	echo master
	return 1
}
git_previous_branch () {
	local ref
	ref=$(__git_prompt_git rev-parse --quiet --symbolic-full-name @{-1} 2> /dev/null) 
	local ret=$? 
	if [[ $ret != 0 ]] || [[ -z $ref ]]
	then
		return
	fi
	echo ${ref#refs/heads/}
}
git_prompt_ahead () {
	if [[ -n "$(__git_prompt_git rev-list origin/$(git_current_branch)..HEAD 2> /dev/null)" ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_AHEAD"
	fi
}
git_prompt_behind () {
	if [[ -n "$(__git_prompt_git rev-list HEAD..origin/$(git_current_branch) 2> /dev/null)" ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_BEHIND"
	fi
}
git_prompt_info () {
	if [[ -n "${_OMZ_ASYNC_OUTPUT[_omz_git_prompt_info]}" ]]
	then
		echo -n "${_OMZ_ASYNC_OUTPUT[_omz_git_prompt_info]}"
	fi
}
git_prompt_long_sha () {
	local SHA
	SHA=$(__git_prompt_git rev-parse HEAD 2> /dev/null)  && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}
git_prompt_remote () {
	if [[ -n "$(__git_prompt_git show-ref origin/$(git_current_branch) 2> /dev/null)" ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_REMOTE_EXISTS"
	else
		echo "$ZSH_THEME_GIT_PROMPT_REMOTE_MISSING"
	fi
}
git_prompt_short_sha () {
	local SHA
	SHA=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null)  && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}
git_prompt_status () {
	if [[ -n "${_OMZ_ASYNC_OUTPUT[_omz_git_prompt_status]}" ]]
	then
		echo -n "${_OMZ_ASYNC_OUTPUT[_omz_git_prompt_status]}"
	fi
}
git_remote_status () {
	local remote ahead behind git_remote_status git_remote_status_detailed
	remote=${$(__git_prompt_git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/} 
	if [[ -n ${remote} ]]
	then
		ahead=$(__git_prompt_git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l) 
		behind=$(__git_prompt_git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l) 
		if [[ $ahead -eq 0 ]] && [[ $behind -eq 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE" 
		elif [[ $ahead -gt 0 ]] && [[ $behind -eq 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE" 
			git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))%{$reset_color%}" 
		elif [[ $behind -gt 0 ]] && [[ $ahead -eq 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE" 
			git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))%{$reset_color%}" 
		elif [[ $ahead -gt 0 ]] && [[ $behind -gt 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE" 
			git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))%{$reset_color%}$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))%{$reset_color%}" 
		fi
		if [[ -n $ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_DETAILED ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_PREFIX${remote:gs/%/%%}$git_remote_status_detailed$ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_SUFFIX" 
		fi
		echo $git_remote_status
	fi
}
git_repo_name () {
	local repo_path
	if repo_path="$(__git_prompt_git rev-parse --show-toplevel 2>/dev/null)"  && [[ -n "$repo_path" ]]
	then
		echo ${repo_path:t}
	fi
}
grename () {
	if [[ -z "$1" || -z "$2" ]]
	then
		echo "Usage: $0 old_branch new_branch"
		return 1
	fi
	git branch -m "$1" "$2"
	if git push origin :"$1"
	then
		git push --set-upstream origin "$2"
	fi
}
gunwipall () {
	local _commit=$(git log --grep='--wip--' --invert-grep --max-count=1 --format=format:%H) 
	if [[ "$_commit" != "$(git rev-parse HEAD)" ]]
	then
		git reset $_commit || return 1
	fi
}
handle_completion_insecurities () {
	local -aU insecure_dirs
	insecure_dirs=(${(f@):-"$(compaudit 2>/dev/null)"}) 
	[[ -z "${insecure_dirs}" ]] && return
	print "[oh-my-zsh] Insecure completion-dependent directories detected:"
	ls -ld "${(@)insecure_dirs}"
	cat <<EOD

[oh-my-zsh] For safety, we will not load completions from these directories until
[oh-my-zsh] you fix their permissions and ownership and restart zsh.
[oh-my-zsh] See the above list for directories with group or other writability.

[oh-my-zsh] To fix your permissions you can do so by disabling
[oh-my-zsh] the write permission of "group" and "others" and making sure that the
[oh-my-zsh] owner of these directories is either root or your current user.
[oh-my-zsh] The following command may help:
[oh-my-zsh]     compaudit | xargs chmod g-w,o-w

[oh-my-zsh] If the above didn't help or you want to skip the verification of
[oh-my-zsh] insecure directories you can set the variable ZSH_DISABLE_COMPFIX to
[oh-my-zsh] "true" before oh-my-zsh is sourced in your zshrc file.

EOD
}
hg_prompt_info () {
	return 1
}
is-at-least () {
	emulate -L zsh
	local IFS=".-" min_cnt=0 ver_cnt=0 part min_ver version order 
	min_ver=(${=1}) 
	version=(${=2:-$ZSH_VERSION} 0) 
	while (( $min_cnt <= ${#min_ver} ))
	do
		while [[ "$part" != <-> ]]
		do
			(( ++ver_cnt > ${#version} )) && return 0
			if [[ ${version[ver_cnt]} = *[0-9][^0-9]* ]]
			then
				order=(${version[ver_cnt]} ${min_ver[ver_cnt]}) 
				if [[ ${version[ver_cnt]} = <->* ]]
				then
					[[ $order != ${${(On)order}} ]] && return 1
				else
					[[ $order != ${${(O)order}} ]] && return 1
				fi
				[[ $order[1] != $order[2] ]] && return 0
			fi
			part=${version[ver_cnt]##*[^0-9]} 
		done
		while true
		do
			(( ++min_cnt > ${#min_ver} )) && return 0
			[[ ${min_ver[min_cnt]} = <-> ]] && break
		done
		(( part > min_ver[min_cnt] )) && return 0
		(( part < min_ver[min_cnt] )) && return 1
		part='' 
	done
}
is_plugin () {
	local base_dir=$1 
	local name=$2 
	builtin test -f $base_dir/plugins/$name/$name.plugin.zsh || builtin test -f $base_dir/plugins/$name/_$name
}
is_theme () {
	local base_dir=$1 
	local name=$2 
	builtin test -f $base_dir/$name.zsh-theme
}
itunes () {
	local APP_NAME=Music sw_vers=$(sw_vers -productVersion 2>/dev/null) 
	autoload is-at-least
	if [[ -z "$sw_vers" ]] || is-at-least 10.15 $sw_vers
	then
		if [[ $0 = itunes ]]
		then
			echo The itunes function name is deprecated. Use \'music\' instead. >&2
			return 1
		fi
	else
		APP_NAME=iTunes 
	fi
	local opt=$1 playlist=$2 
	(( $# > 0 )) && shift
	case "$opt" in
		(launch | play | pause | stop | rewind | resume | quit)  ;;
		(mute) opt="set mute to true"  ;;
		(unmute) opt="set mute to false"  ;;
		(next | previous) opt="$opt track"  ;;
		(vol) local new_volume volume=$(osascript -e "tell application \"$APP_NAME\" to get sound volume") 
			if [[ $# -eq 0 ]]
			then
				echo "Current volume is ${volume}."
				return 0
			fi
			case $1 in
				(up) new_volume=$((volume + 10 < 100 ? volume + 10 : 100))  ;;
				(down) new_volume=$((volume - 10 > 0 ? volume - 10 : 0))  ;;
				(<0-100>) new_volume=$1  ;;
				(*) echo "'$1' is not valid. Expected <0-100>, up or down."
					return 1 ;;
			esac
			opt="set sound volume to ${new_volume}"  ;;
		(playlist) if [[ -n "$playlist" ]]
			then
				osascript 2> /dev/null <<EOF
          tell application "$APP_NAME"
            set new_playlist to "$playlist" as string
            play playlist new_playlist
          end tell
EOF
				if [[ $? -eq 0 ]]
				then
					opt="play" 
				else
					opt="stop" 
				fi
			else
				opt="set allPlaylists to (get name of every playlist)" 
			fi ;;
		(playing | status) local currenttrack currentartist state=$(osascript -e "tell application \"$APP_NAME\" to player state as string") 
			if [[ "$state" = "playing" ]]
			then
				currenttrack=$(osascript -e "tell application \"$APP_NAME\" to name of current track as string") 
				currentartist=$(osascript -e "tell application \"$APP_NAME\" to artist of current track as string") 
				echo -E "Listening to ${fg[yellow]}${currenttrack}${reset_color} by ${fg[yellow]}${currentartist}${reset_color}"
			else
				echo "$APP_NAME is $state"
			fi
			return 0 ;;
		(shuf | shuff | shuffle) local state=$1 
			if [[ -n "$state" && "$state" != (on|off|toggle) ]]
			then
				print "Usage: $0 shuffle [on|off|toggle]. Invalid option."
				return 1
			fi
			case "$state" in
				(on | off) osascript > /dev/null 2>&1 <<EOF
            tell application "System Events" to perform action "AXPress" of (menu item "${state}" of menu "Shuffle" of menu item "Shuffle" of menu "Controls" of menu bar item "Controls" of menu bar 1 of application process "iTunes" )
EOF
					return 0 ;;
				(toggle | *) osascript > /dev/null 2>&1 <<EOF
            tell application "System Events" to perform action "AXPress" of (button 2 of process "iTunes"'s window "iTunes"'s scroll area 1)
EOF
					return 0 ;;
			esac ;;
		("" | -h | --help) echo "Usage: $0 <option>"
			echo "option:"
			echo "\t-h|--help\tShow this message and exit"
			echo "\tlaunch|play|pause|stop|rewind|resume|quit"
			echo "\tmute|unmute\tMute or unmute $APP_NAME"
			echo "\tnext|previous\tPlay next or previous track"
			echo "\tshuf|shuffle [on|off|toggle]\tSet shuffled playback. Default: toggle. Note: toggle doesn't support the MiniPlayer."
			echo "\tvol [0-100|up|down]\tGet or set the volume. 0 to 100 sets the volume. 'up' / 'down' increases / decreases by 10 points. No argument displays current volume."
			echo "\tplaying|status\tShow what song is currently playing in Music."
			echo "\tplaylist [playlist name]\t Play specific playlist"
			return 0 ;;
		(*) print "Unknown option: $opt"
			return 1 ;;
	esac
	osascript -e "tell application \"$APP_NAME\" to $opt"
}
jenv_prompt_info () {
	return 1
}
list_api_keys () {
	echo "Available API keys:"
	for key in "${(k)API_KEYS[@]}"
	do
		local path="${API_KEYS[$key]}" 
		local is_default="" 
		if [[ " ${DEFAULT_KEYS[@]} " =~ " ${key} " ]]
		then
			is_default=" (loaded by default)" 
		fi
		echo "  $key: $path$is_default"
	done
}
load_all_keys () {
	if ! check_op_cli
	then
		return 1
	fi
	if ! ensure_op_signin
	then
		return 1
	fi
	local success=true 
	for key_name in "${DEFAULT_KEYS[@]}"
	do
		if ! load_api_key "$key_name"
		then
			success=false 
		fi
	done
	if $success
	then
		echo "All default API keys loaded successfully"
		return 0
	else
		echo "Some API keys failed to load"
		return 1
	fi
}
load_anthropic_key () {
	load_api_key "ANTHROPIC_API_KEY"
}
load_api_key () {
	local key_name="$1" 
	local op_path="${API_KEYS[$key_name]}" 
	if [[ -z "$op_path" ]]
	then
		echo "Error: Unknown API key '$key_name'"
		echo "Available keys: ${(k)API_KEYS}"
		return 1
	fi
	if [[ -z "${(P)key_name}" ]]
	then
		echo "$key_name not found in environment, fetching from 1Password..."
		if ! check_op_cli
		then
			return 1
		fi
		local key=$(op read "$op_path" 2>/dev/null) 
		if [[ -n "$key" ]]
		then
			export "$key_name"="$key"
			echo "$key_name has been set from 1Password"
		else
			echo "Failed to retrieve $key_name from 1Password at path: $op_path"
			return 1
		fi
	else
		echo "$key_name is already set"
	fi
	return 0
}
load_azure_openai_key () {
	load_api_key "AZURE_OPENAI_API_KEY"
}
load_cohere_key () {
	load_api_key "COHERE_API_KEY"
}
load_gemini_key () {
	load_api_key "GEMINI_API_KEY"
}
load_groq_key () {
	load_api_key "GROQ_API_KEY"
}
load_huggingface_key () {
	load_api_key "HUGGINGFACE_API_KEY"
}
load_mistral_key () {
	load_api_key "MISTRAL_API_KEY"
}
load_openai_key () {
	load_api_key "OPENAI_API_KEY"
}
load_perplexity_key () {
	load_api_key "PERPLEXITY_API_KEY"
}
load_replicate_key () {
	load_api_key "REPLICATE_API_KEY"
}
load_stability_key () {
	load_api_key "STABILITY_API_KEY"
}
load_together_key () {
	load_api_key "TOGETHER_API_KEY"
}
man () {
	colored $0 "$@"
}
man-preview () {
	[[ $# -eq 0 ]] && echo "Usage: $0 command1 [command2 ...]" >&2 && return 1
	local page
	for page in "${(@f)"$(command man -w $@)"}"
	do
		command mandoc -Tpdf $page | open -f -a Preview
	done
}
mise () {
	local command
	command="${1:-}" 
	if [ "$#" = 0 ]
	then
		command /opt/homebrew/bin/mise
		return
	fi
	shift
	case "$command" in
		(deactivate | shell | sh) if [[ ! " $@ " =~ " --help " ]] && [[ ! " $@ " =~ " -h " ]]
			then
				eval "$(command /opt/homebrew/bin/mise "$command" "$@")"
				return $?
			fi ;;
	esac
	command /opt/homebrew/bin/mise "$command" "$@"
}
mkcd () {
	mkdir -p $@ && cd ${@:$#}
}
mkv () {
	local name="${1:-$PYTHON_VENV_NAME}" 
	local venvpath="${name:P}" 
	python3 -m venv "${name}" || return
	echo "Created venv in '${venvpath}'" >&2
	vrun "${name}"
}
music () {
	local APP_NAME=Music sw_vers=$(sw_vers -productVersion 2>/dev/null) 
	autoload is-at-least
	if [[ -z "$sw_vers" ]] || is-at-least 10.15 $sw_vers
	then
		if [[ $0 = itunes ]]
		then
			echo The itunes function name is deprecated. Use \'music\' instead. >&2
			return 1
		fi
	else
		APP_NAME=iTunes 
	fi
	local opt=$1 playlist=$2 
	(( $# > 0 )) && shift
	case "$opt" in
		(launch | play | pause | stop | rewind | resume | quit)  ;;
		(mute) opt="set mute to true"  ;;
		(unmute) opt="set mute to false"  ;;
		(next | previous) opt="$opt track"  ;;
		(vol) local new_volume volume=$(osascript -e "tell application \"$APP_NAME\" to get sound volume") 
			if [[ $# -eq 0 ]]
			then
				echo "Current volume is ${volume}."
				return 0
			fi
			case $1 in
				(up) new_volume=$((volume + 10 < 100 ? volume + 10 : 100))  ;;
				(down) new_volume=$((volume - 10 > 0 ? volume - 10 : 0))  ;;
				(<0-100>) new_volume=$1  ;;
				(*) echo "'$1' is not valid. Expected <0-100>, up or down."
					return 1 ;;
			esac
			opt="set sound volume to ${new_volume}"  ;;
		(playlist) if [[ -n "$playlist" ]]
			then
				osascript 2> /dev/null <<EOF
          tell application "$APP_NAME"
            set new_playlist to "$playlist" as string
            play playlist new_playlist
          end tell
EOF
				if [[ $? -eq 0 ]]
				then
					opt="play" 
				else
					opt="stop" 
				fi
			else
				opt="set allPlaylists to (get name of every playlist)" 
			fi ;;
		(playing | status) local currenttrack currentartist state=$(osascript -e "tell application \"$APP_NAME\" to player state as string") 
			if [[ "$state" = "playing" ]]
			then
				currenttrack=$(osascript -e "tell application \"$APP_NAME\" to name of current track as string") 
				currentartist=$(osascript -e "tell application \"$APP_NAME\" to artist of current track as string") 
				echo -E "Listening to ${fg[yellow]}${currenttrack}${reset_color} by ${fg[yellow]}${currentartist}${reset_color}"
			else
				echo "$APP_NAME is $state"
			fi
			return 0 ;;
		(shuf | shuff | shuffle) local state=$1 
			if [[ -n "$state" && "$state" != (on|off|toggle) ]]
			then
				print "Usage: $0 shuffle [on|off|toggle]. Invalid option."
				return 1
			fi
			case "$state" in
				(on | off) osascript > /dev/null 2>&1 <<EOF
            tell application "System Events" to perform action "AXPress" of (menu item "${state}" of menu "Shuffle" of menu item "Shuffle" of menu "Controls" of menu bar item "Controls" of menu bar 1 of application process "iTunes" )
EOF
					return 0 ;;
				(toggle | *) osascript > /dev/null 2>&1 <<EOF
            tell application "System Events" to perform action "AXPress" of (button 2 of process "iTunes"'s window "iTunes"'s scroll area 1)
EOF
					return 0 ;;
			esac ;;
		("" | -h | --help) echo "Usage: $0 <option>"
			echo "option:"
			echo "\t-h|--help\tShow this message and exit"
			echo "\tlaunch|play|pause|stop|rewind|resume|quit"
			echo "\tmute|unmute\tMute or unmute $APP_NAME"
			echo "\tnext|previous\tPlay next or previous track"
			echo "\tshuf|shuffle [on|off|toggle]\tSet shuffled playback. Default: toggle. Note: toggle doesn't support the MiniPlayer."
			echo "\tvol [0-100|up|down]\tGet or set the volume. 0 to 100 sets the volume. 'up' / 'down' increases / decreases by 10 points. No argument displays current volume."
			echo "\tplaying|status\tShow what song is currently playing in Music."
			echo "\tplaylist [playlist name]\t Play specific playlist"
			return 0 ;;
		(*) print "Unknown option: $opt"
			return 1 ;;
	esac
	osascript -e "tell application \"$APP_NAME\" to $opt"
}
nvm_prompt_info () {
	which nvm &> /dev/null || return
	local nvm_prompt=${$(nvm current)#v} 
	echo "${ZSH_THEME_NVM_PROMPT_PREFIX}${nvm_prompt:gs/%/%%}${ZSH_THEME_NVM_PROMPT_SUFFIX}"
}
ofd () {
	if (( ! $# ))
	then
		open_command $PWD
	else
		open_command $@
	fi
}
omz () {
	setopt localoptions noksharrays
	[[ $# -gt 0 ]] || {
		_omz::help
		return 1
	}
	local command="$1" 
	shift
	(( ${+functions[_omz::$command]} )) || {
		_omz::help
		return 1
	}
	_omz::$command "$@"
}
omz_diagnostic_dump () {
	emulate -L zsh
	builtin echo "Generating diagnostic dump; please be patient..."
	local thisfcn=omz_diagnostic_dump 
	local -A opts
	local opt_verbose opt_noverbose opt_outfile
	local timestamp=$(date +%Y%m%d-%H%M%S) 
	local outfile=omz_diagdump_$timestamp.txt 
	builtin zparseopts -A opts -D -- "v+=opt_verbose" "V+=opt_noverbose"
	local verbose n_verbose=${#opt_verbose} n_noverbose=${#opt_noverbose} 
	(( verbose = 1 + n_verbose - n_noverbose ))
	if [[ ${#*} > 0 ]]
	then
		opt_outfile=$1 
	fi
	if [[ ${#*} > 1 ]]
	then
		builtin echo "$thisfcn: error: too many arguments" >&2
		return 1
	fi
	if [[ -n "$opt_outfile" ]]
	then
		outfile="$opt_outfile" 
	fi
	_omz_diag_dump_one_big_text &> "$outfile"
	if [[ $? != 0 ]]
	then
		builtin echo "$thisfcn: error while creating diagnostic dump; see $outfile for details"
	fi
	builtin echo
	builtin echo Diagnostic dump file created at: "$outfile"
	builtin echo
	builtin echo To share this with OMZ developers, post it as a gist on GitHub
	builtin echo at "https://gist.github.com" and share the link to the gist.
	builtin echo
	builtin echo "WARNING: This dump file contains all your zsh and omz configuration files,"
	builtin echo "so don't share it publicly if there's sensitive information in them."
	builtin echo
}
omz_history () {
	local clear list stamp REPLY
	zparseopts -E -D c=clear l=list f=stamp E=stamp i=stamp t:=stamp
	if [[ -n "$clear" ]]
	then
		print -nu2 "This action will irreversibly delete your command history. Are you sure? [y/N] "
		builtin read -E
		[[ "$REPLY" = [yY] ]] || return 0
		print -nu2 >| "$HISTFILE"
		fc -p "$HISTFILE"
		print -u2 History file deleted.
	elif [[ $# -eq 0 ]]
	then
		builtin fc "${stamp[@]}" -l 1
	else
		builtin fc "${stamp[@]}" -l "$@"
	fi
}
omz_termsupport_cwd () {
	setopt localoptions unset
	local URL_HOST URL_PATH
	URL_HOST="$(omz_urlencode -P $HOST)"  || return 1
	URL_PATH="$(omz_urlencode -P $PWD)"  || return 1
	[[ -z "$KONSOLE_PROFILE_NAME" && -z "$KONSOLE_DBUS_SESSION" ]] || URL_HOST="" 
	printf "\e]7;file://%s%s\e\\" "${URL_HOST}" "${URL_PATH}"
}
omz_termsupport_precmd () {
	[[ "${DISABLE_AUTO_TITLE:-}" != true ]] || return 0
	title "$ZSH_THEME_TERM_TAB_TITLE_IDLE" "$ZSH_THEME_TERM_TITLE_IDLE"
}
omz_termsupport_preexec () {
	[[ "${DISABLE_AUTO_TITLE:-}" != true ]] || return
	emulate -L zsh
	setopt extended_glob
	local -a cmdargs
	cmdargs=("${(z)2}") 
	if [[ "${cmdargs[1]}" = fg ]]
	then
		local job_id jobspec="${cmdargs[2]#%}" 
		case "$jobspec" in
			(<->) job_id=${jobspec}  ;;
			("" | % | +) job_id=${(k)jobstates[(r)*:+:*]}  ;;
			(-) job_id=${(k)jobstates[(r)*:-:*]}  ;;
			([?]*) job_id=${(k)jobtexts[(r)*${(Q)jobspec}*]}  ;;
			(*) job_id=${(k)jobtexts[(r)${(Q)jobspec}*]}  ;;
		esac
		if [[ -n "${jobtexts[$job_id]}" ]]
		then
			1="${jobtexts[$job_id]}" 
			2="${jobtexts[$job_id]}" 
		fi
	fi
	local CMD="${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}" 
	local LINE="${2:gs/%/%%}" 
	title "$CMD" "%100>...>${LINE}%<<"
}
omz_urldecode () {
	emulate -L zsh
	local encoded_url=$1 
	local caller_encoding=$langinfo[CODESET] 
	local LC_ALL=C 
	export LC_ALL
	local tmp=${encoded_url:gs/+/ /} 
	tmp=${tmp:gs/\\/\\\\/} 
	tmp=${tmp:gs/%/\\x/} 
	local decoded="$(printf -- "$tmp")" 
	local -a safe_encodings
	safe_encodings=(UTF-8 utf8 US-ASCII) 
	if [[ -z ${safe_encodings[(r)$caller_encoding]} ]]
	then
		decoded=$(echo -E "$decoded" | iconv -f UTF-8 -t $caller_encoding) 
		if [[ $? != 0 ]]
		then
			echo "Error converting string from UTF-8 to $caller_encoding" >&2
			return 1
		fi
	fi
	echo -E "$decoded"
}
omz_urlencode () {
	emulate -L zsh
	setopt norematchpcre
	local -a opts
	zparseopts -D -E -a opts r m P
	local in_str="$@" 
	local url_str="" 
	local spaces_as_plus
	if [[ -z $opts[(r)-P] ]]
	then
		spaces_as_plus=1 
	fi
	local str="$in_str" 
	local encoding=$langinfo[CODESET] 
	local safe_encodings
	safe_encodings=(UTF-8 utf8 US-ASCII) 
	if [[ -z ${safe_encodings[(r)$encoding]} ]]
	then
		str=$(echo -E "$str" | iconv -f $encoding -t UTF-8) 
		if [[ $? != 0 ]]
		then
			echo "Error converting string from $encoding to UTF-8" >&2
			return 1
		fi
	fi
	local i byte ord LC_ALL=C 
	export LC_ALL
	local reserved=';/?:@&=+$,' 
	local mark='_.!~*''()-' 
	local dont_escape="[A-Za-z0-9" 
	if [[ -z $opts[(r)-r] ]]
	then
		dont_escape+=$reserved 
	fi
	if [[ -z $opts[(r)-m] ]]
	then
		dont_escape+=$mark 
	fi
	dont_escape+="]" 
	local url_str="" 
	for ((i = 1; i <= ${#str}; ++i )) do
		byte="$str[i]" 
		if [[ "$byte" =~ "$dont_escape" ]]
		then
			url_str+="$byte" 
		else
			if [[ "$byte" == " " && -n $spaces_as_plus ]]
			then
				url_str+="+" 
			elif [[ "$PREFIX" = *com.termux* ]]
			then
				url_str+="$byte" 
			else
				ord=$(( [##16] #byte )) 
				url_str+="%$ord" 
			fi
		fi
	done
	echo -E "$url_str"
}
open_command () {
	local open_cmd
	case "$OSTYPE" in
		(darwin*) open_cmd='open'  ;;
		(cygwin*) open_cmd='cygstart'  ;;
		(linux*) [[ "$(uname -r)" != *icrosoft* ]] && open_cmd='nohup xdg-open'  || {
				open_cmd='cmd.exe /c start ""' 
				[[ -e "$1" ]] && {
					1="$(wslpath -w "${1:a}")"  || return 1
				}
				[[ "$1" = (http|https)://* ]] && {
					1="$(echo "$1" | sed -E 's/([&|()<>^])/^\1/g')"  || return 1
				}
			} ;;
		(msys*) open_cmd='start ""'  ;;
		(*) echo "Platform $OSTYPE not supported"
			return 1 ;;
	esac
	if [[ -n "$BROWSER" && "$1" = (http|https)://* ]]
	then
		"$BROWSER" "$@"
		return
	fi
	${=open_cmd} "$@" &> /dev/null
}
parse_git_dirty () {
	local STATUS
	local -a FLAGS
	FLAGS=('--porcelain') 
	if [[ "$(__git_prompt_git config --get oh-my-zsh.hide-dirty)" != "1" ]]
	then
		if [[ "${DISABLE_UNTRACKED_FILES_DIRTY:-}" == "true" ]]
		then
			FLAGS+='--untracked-files=no' 
		fi
		case "${GIT_STATUS_IGNORE_SUBMODULES:-}" in
			(git)  ;;
			(*) FLAGS+="--ignore-submodules=${GIT_STATUS_IGNORE_SUBMODULES:-dirty}"  ;;
		esac
		STATUS=$(__git_prompt_git status ${FLAGS} 2> /dev/null | tail -n 1) 
	fi
	if [[ -n $STATUS ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
	else
		echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
	fi
}
pfd () {
	osascript 2> /dev/null <<EOF
    tell application "Finder"
      return POSIX path of (insertion location as alias)
    end tell
EOF
}
pfs () {
	osascript 2> /dev/null <<EOF
    set output to ""
    tell application "Finder" to set the_selection to selection
    set item_count to count the_selection
    repeat with item_index from 1 to count the_selection
      if item_index is less than item_count then set the_delimiter to "\n"
      if item_index is item_count then set the_delimiter to ""
      set output to output & ((item item_index of the_selection as alias)'s POSIX path) & the_delimiter
    end repeat
EOF
}
pipig () {
	noglob pip install "git+https://github.com/$1.git"
}
pipigb () {
	noglob pip install "git+https://github.com/$1.git@$2"
}
pipigp () {
	noglob pip install "git+https://github.com/$1.git@refs/pull/$2/head"
}
pipunall () {
	local xargs="xargs --no-run-if-empty" 
	xargs --version 2> /dev/null | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv} -q GNU || xargs="xargs" 
	noglob pip list --format freeze | cut -d= -f1 | ${=xargs} pip uninstall
}
pipupall () {
	local xargs="xargs --no-run-if-empty" 
	xargs --version 2> /dev/null | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv} -q GNU || xargs="xargs" 
	noglob pip list --outdated | awk 'NR > 2 { print $1 }' | ${=xargs} pip install --upgrade
}
pushdf () {
	pushd "$(pfd)"
}
pxd () {
	dirname $(osascript 2>/dev/null <<EOF
    if application "Xcode" is running then
      tell application "Xcode"
        return path of active workspace document
      end tell
    end if
EOF
)
}
pyclean () {
	find "${@:-.}" -type f -name "*.py[co]" -delete
	find "${@:-.}" -type d -name "__pycache__" -delete
	find "${@:-.}" -depth -type d -name ".mypy_cache" -exec rm -r "{}" +
	find "${@:-.}" -depth -type d -name ".pytest_cache" -exec rm -r "{}" +
}
pyenv_prompt_info () {
	return 1
}
pyuserpaths () {
	setopt localoptions extendedglob
	local user_base="${PYTHONUSERBASE:-"${HOME}/.local"}" 
	local python version site_pkgs
	for python in python2 python3
	do
		(( ${+commands[$python]} )) || continue
		version=${(M)${"$($python -V 2>&1)":7}#[^.]##.[^.]##} 
		site_pkgs="${user_base}/lib/python${version}/site-packages" 
		[[ -d "$site_pkgs" && ! "$PYTHONPATH" =~ (^|:)"$site_pkgs"(:|$) ]] || continue
		export PYTHONPATH="${site_pkgs}${PYTHONPATH+":${PYTHONPATH}"}" 
	done
}
quick-look () {
	(( $# > 0 )) && qlmanage -p $* &> /dev/null &
}
rbenv_prompt_info () {
	return 1
}
regexp-replace () {
	argv=("$1" "$2" "$3") 
	4=0 
	[[ -o re_match_pcre ]] && 4=1 
	emulate -L zsh
	local MATCH MBEGIN MEND
	local -a match mbegin mend
	if (( $4 ))
	then
		zmodload zsh/pcre || return 2
		pcre_compile -- "$2" && pcre_study || return 2
		4=0 6= 
		local ZPCRE_OP
		while pcre_match -b -n $4 -- "${(P)1}"
		do
			5=${(e)3} 
			argv+=(${(s: :)ZPCRE_OP} "$5") 
			4=$((argv[-2] + (argv[-3] == argv[-2]))) 
		done
		(($# > 6)) || return
		set +o multibyte
		5= 6=1 
		for 2 3 4 in "$@[7,-1]"
		do
			5+=${(P)1[$6,$2]}$4 
			6=$(($3 + 1)) 
		done
		5+=${(P)1[$6,-1]} 
	else
		4=${(P)1} 
		while [[ -n $4 ]]
		do
			if [[ $4 =~ $2 ]]
			then
				5+=${4[1,MBEGIN-1]}${(e)3} 
				if ((MEND < MBEGIN))
				then
					((MEND++))
					5+=${4[1]} 
				fi
				4=${4[MEND+1,-1]} 
				6=1 
			else
				break
			fi
		done
		[[ -n $6 ]] || return
		5+=$4 
	fi
	eval $1=\$5
}
remote_console () {
	/usr/bin/env ssh $1 "( cd $2 && ruby script/console production )"
}
rmdsstore () {
	find "${@:-.}" -type f -name .DS_Store -delete
}
ruby_prompt_info () {
	echo "$(rvm_prompt_info || rbenv_prompt_info || chruby_prompt_info)"
}
rvm_prompt_info () {
	[ -f $HOME/.rvm/bin/rvm-prompt ] || return 1
	local rvm_prompt
	rvm_prompt=$($HOME/.rvm/bin/rvm-prompt ${=ZSH_THEME_RVM_PROMPT_OPTIONS} 2>/dev/null) 
	[[ -z "${rvm_prompt}" ]] && return 1
	echo "${ZSH_THEME_RUBY_PROMPT_PREFIX}${rvm_prompt:gs/%/%%}${ZSH_THEME_RUBY_PROMPT_SUFFIX}"
}
spectrum_bls () {
	setopt localoptions nopromptsubst
	local ZSH_SPECTRUM_TEXT=${ZSH_SPECTRUM_TEXT:-Arma virumque cano Troiae qui primus ab oris} 
	for code in {000..255}
	do
		print -P -- "$code: ${BG[$code]}${ZSH_SPECTRUM_TEXT}%{$reset_color%}"
	done
}
spectrum_ls () {
	setopt localoptions nopromptsubst
	local ZSH_SPECTRUM_TEXT=${ZSH_SPECTRUM_TEXT:-Arma virumque cano Troiae qui primus ab oris} 
	for code in {000..255}
	do
		print -P -- "$code: ${FG[$code]}${ZSH_SPECTRUM_TEXT}%{$reset_color%}"
	done
}
split_tab () {
	local command="cd \\\"$PWD\\\"; clear" 
	(( $# > 0 )) && command="${command}; $*" 
	local the_app=$(_omz_macos_get_frontmost_app) 
	if [[ "$the_app" == 'iTerm' ]]
	then
		osascript 2> /dev/null <<EOF
      tell application "iTerm" to activate

      tell application "System Events"
        tell process "iTerm"
          tell menu item "Split Horizontally With Current Profile" of menu "Shell" of menu bar item "Shell" of menu bar 1
            click
          end tell
        end tell
        keystroke "${command} \n"
      end tell
EOF
	elif [[ "$the_app" == 'iTerm2' ]]
	then
		osascript <<EOF
      tell application "iTerm2"
        tell current session of first window
          set newSession to (split horizontally with same profile)
          tell newSession
            write text "${command}"
            select
          end tell
        end tell
      end tell
EOF
	elif [[ "$the_app" == 'Hyper' ]]
	then
		osascript > /dev/null <<EOF
    tell application "System Events"
      tell process "Hyper"
        tell menu item "Split Horizontally" of menu "Shell" of menu bar 1
          click
        end tell
      end tell
      delay 1
      keystroke "${command} \n"
    end tell
EOF
	elif [[ "$the_app" == 'Tabby' ]]
	then
		osascript > /dev/null <<EOF
      tell application "System Events"
        tell process "Tabby" to keystroke "d" using command down
      end tell
EOF
	elif [[ "$the_app" == 'ghostty' ]]
	then
		osascript > /dev/null <<EOF
      tell application "System Events"
        tell process "Ghostty" to keystroke "d" using command down
      end tell
EOF
	else
		echo "$0: unsupported terminal app: $the_app" >&2
		return 1
	fi
}
spotify () {
	USER_CONFIG_DEFAULTS="CLIENT_ID=\"\"\nCLIENT_SECRET=\"\"" 
	USER_CONFIG_FILE="${HOME}/.shpotify.cfg" 
	if ! [[ -f "${USER_CONFIG_FILE}" ]]
	then
		touch "${USER_CONFIG_FILE}"
		echo -e "${USER_CONFIG_DEFAULTS}" > "${USER_CONFIG_FILE}"
	fi
	source "${USER_CONFIG_FILE}"
	VOL_INCREMENT=10 
	showAPIHelp () {
		echo
		echo "Connecting to Spotify's API:"
		echo
		echo "  This command line application needs to connect to Spotify's API in order to"
		echo "  find music by name. It is very likely you want this feature!"
		echo
		echo "  To get this to work, you need to sign up (or in) and create an 'Application' at:"
		echo "  https://developer.spotify.com/dashboard/create"
		echo
		echo "  Once you've created an application, find the 'Client ID' and 'Client Secret'"
		echo "  values, and enter them into your shpotify config file at '${USER_CONFIG_FILE}'"
		echo
		echo "  Be sure to quote your values and don't add any extra spaces!"
		echo "  When done, it should look like this (but with your own values):"
		echo '  CLIENT_ID="abc01de2fghijk345lmnop"'
		echo '  CLIENT_SECRET="qr6stu789vwxyz"'
	}
	showHelp () {
		echo "Usage:"
		echo
		echo "  `basename $0` <command>"
		echo
		echo "Commands:"
		echo
		echo "  play                         # Resumes playback where Spotify last left off."
		echo "  play <song name>             # Finds a song by name and plays it."
		echo "  play album <album name>      # Finds an album by name and plays it."
		echo "  play artist <artist name>    # Finds an artist by name and plays it."
		echo "  play list <playlist name>    # Finds a playlist by name and plays it."
		echo "  play uri <uri>               # Play songs from specific uri."
		echo
		echo "  next                         # Skips to the next song in a playlist."
		echo "  prev                         # Returns to the previous song in a playlist."
		echo "  replay                       # Replays the current track from the beginning."
		echo "  pos <time>                   # Jumps to a time (in secs) in the current song."
		echo "  pause                        # Pauses (or resumes) Spotify playback."
		echo "  stop                         # Stops playback."
		echo "  quit                         # Stops playback and quits Spotify."
		echo
		echo "  vol up                       # Increases the volume by 10%."
		echo "  vol down                     # Decreases the volume by 10%."
		echo "  vol <amount>                 # Sets the volume to an amount between 0 and 100."
		echo "  vol [show]                   # Shows the current Spotify volume."
		echo
		echo "  status                       # Shows the current player status."
		echo "  status artist                # Shows the currently playing artist."
		echo "  status album                 # Shows the currently playing album."
		echo "  status track                 # Shows the currently playing track."
		echo
		echo "  share                        # Displays the current song's Spotify URL and URI."
		echo "  share url                    # Displays the current song's Spotify URL and copies it to the clipboard."
		echo "  share uri                    # Displays the current song's Spotify URI and copies it to the clipboard."
		echo
		echo "  toggle shuffle               # Toggles shuffle playback mode."
		echo "  toggle repeat                # Toggles repeat playback mode."
		showAPIHelp
	}
	cecho () {
		bold=$(tput bold) 
		green=$(tput setaf 2) 
		reset=$(tput sgr0) 
		echo $bold$green"$1"$reset
	}
	showArtist () {
		echo `osascript -e 'tell application "Spotify" to artist of current track as string'`
	}
	showAlbum () {
		echo `osascript -e 'tell application "Spotify" to album of current track as string'`
	}
	showTrack () {
		echo `osascript -e 'tell application "Spotify" to name of current track as string'`
	}
	showStatus () {
		state=`osascript -e 'tell application "Spotify" to player state as string'` 
		cecho "Spotify is currently $state."
		duration=`osascript -e 'tell application "Spotify"
            set durSec to (duration of current track / 1000) as text
            set tM to (round (durSec / 60) rounding down) as text
            if length of ((durSec mod 60 div 1) as text) is greater than 1 then
                set tS to (durSec mod 60 div 1) as text
            else
                set tS to ("0" & (durSec mod 60 div 1)) as text
            end if
            set myTime to tM as text & ":" & tS as text
            end tell
            return myTime'` 
		position=`osascript -e 'tell application "Spotify"
            set pos to player position
            set nM to (round (pos / 60) rounding down) as text
            if length of ((round (pos mod 60) rounding down) as text) is greater than 1 then
                set nS to (round (pos mod 60) rounding down) as text
            else
                set nS to ("0" & (round (pos mod 60) rounding down)) as text
            end if
            set nowAt to nM as text & ":" & nS as text
            end tell
            return nowAt'` 
		echo -e $reset"Artist: $(showArtist)\nAlbum: $(showAlbum)\nTrack: $(showTrack) \nPosition: $position / $duration"
	}
	if [ $# = 0 ]
	then
		showHelp
	else
		if [ ! -d /Applications/Spotify.app ] && [ ! -d $HOME/Applications/Spotify.app ]
		then
			echo "The Spotify application must be installed."
			return 1
		fi
		if [ $(osascript -e 'application "Spotify" is running') = "false" ]
		then
			osascript -e 'tell application "Spotify" to activate' || return 1
			sleep 2
		fi
	fi
	while [ $# -gt 0 ]
	do
		arg=$1 
		case $arg in
			("play") if [ $# != 1 ]
				then
					array=($@) 
					len=${#array[@]} 
					SPOTIFY_SEARCH_API="https://api.spotify.com/v1/search" 
					SPOTIFY_TOKEN_URI="https://accounts.spotify.com/api/token" 
					if [ -z "${CLIENT_ID}" ]
					then
						cecho "Invalid Client ID, please update ${USER_CONFIG_FILE}"
						showAPIHelp
						return 1
					fi
					if [ -z "${CLIENT_SECRET}" ]
					then
						cecho "Invalid Client Secret, please update ${USER_CONFIG_FILE}"
						showAPIHelp
						return 1
					fi
					SHPOTIFY_CREDENTIALS=$(printf "${CLIENT_ID}:${CLIENT_SECRET}" | base64 | tr -d "\n"|tr -d '\r') 
					SPOTIFY_PLAY_URI="" 
					getAccessToken () {
						cecho "Connecting to Spotify's API"
						SPOTIFY_TOKEN_RESPONSE_DATA=$( \
                        curl "${SPOTIFY_TOKEN_URI}" \
                            --silent \
                            -X "POST" \
                            -H "Authorization: Basic ${SHPOTIFY_CREDENTIALS}" \
                            -d "grant_type=client_credentials" \
                    ) 
						if ! [[ "${SPOTIFY_TOKEN_RESPONSE_DATA}" =~ "access_token" ]]
						then
							cecho "Authorization failed, please check ${USER_CONFG_FILE}"
							cecho "${SPOTIFY_TOKEN_RESPONSE_DATA}"
							showAPIHelp
							return 1
						fi
						SPOTIFY_ACCESS_TOKEN=$( \
                        printf "${SPOTIFY_TOKEN_RESPONSE_DATA}" \
                        | command grep -E -o '"access_token":".*",' \
                        | sed 's/"access_token"://g' \
                        | sed 's/"//g' \
                        | sed 's/,.*//g' \
                    ) 
					}
					searchAndPlay () {
						type="$1" 
						Q="$2" 
						getAccessToken
						cecho "Searching ${type}s for: $Q"
						SPOTIFY_PLAY_URI=$( \
                        curl -s -G $SPOTIFY_SEARCH_API \
                            -H "Authorization: Bearer ${SPOTIFY_ACCESS_TOKEN}" \
                            -H "Accept: application/json" \
                            --data-urlencode "q=$Q" \
                            -d "type=$type&limit=1&offset=0" \
                        | command grep -E -o "spotify:$type:[a-zA-Z0-9]+" -m 1
                    ) 
					}
					case $2 in
						("list") _args=${array[@]:2:$len} 
							Q=$_args 
							getAccessToken
							cecho "Searching playlists for: $Q"
							results=$( \
                            curl -s -G $SPOTIFY_SEARCH_API --data-urlencode "q=$Q" -d "type=playlist&limit=10&offset=0" -H "Accept: application/json" -H "Authorization: Bearer ${SPOTIFY_ACCESS_TOKEN}" \
                            | command grep -E -o "spotify:playlist:[a-zA-Z0-9]+" -m 10 \
                        ) 
							count=$( \
                            echo "$results" | command grep -c "spotify:playlist" \
                        ) 
							if [ "$count" -gt 0 ]
							then
								random=$(( $RANDOM % $count)) 
								SPOTIFY_PLAY_URI=$( \
                                echo "$results" | awk -v random="$random" '/spotify:playlist:[a-zA-Z0-9]+/{i++}i==random{print; exit}' \
                            ) 
							fi ;;
						("album" | "artist" | "track") _args=${array[@]:2:$len} 
							searchAndPlay $2 "$_args" ;;
						("uri") SPOTIFY_PLAY_URI=${array[@]:2:$len}  ;;
						(*) _args=${array[@]:1:$len} 
							searchAndPlay track "$_args" ;;
					esac
					if [ "$SPOTIFY_PLAY_URI" != "" ]
					then
						if [ "$2" = "uri" ]
						then
							cecho "Playing Spotify URI: $SPOTIFY_PLAY_URI"
						else
							cecho "Playing ($Q Search) -> Spotify URI: $SPOTIFY_PLAY_URI"
						fi
						osascript -e "tell application \"Spotify\" to play track \"$SPOTIFY_PLAY_URI\""
					else
						cecho "No results when searching for $Q"
					fi
				else
					cecho "Playing Spotify."
					osascript -e 'tell application "Spotify" to play'
				fi
				break ;;
			("pause") state=`osascript -e 'tell application "Spotify" to player state as string'` 
				if [ $state = "playing" ]
				then
					cecho "Pausing Spotify."
				else
					cecho "Playing Spotify."
				fi
				osascript -e 'tell application "Spotify" to playpause'
				break ;;
			("stop") state=`osascript -e 'tell application "Spotify" to player state as string'` 
				if [ $state = "playing" ]
				then
					cecho "Pausing Spotify."
					osascript -e 'tell application "Spotify" to playpause'
				else
					cecho "Spotify is already stopped."
				fi
				break ;;
			("quit") cecho "Quitting Spotify."
				osascript -e 'tell application "Spotify" to quit'
				break ;;
			("next") cecho "Going to next track."
				osascript -e 'tell application "Spotify" to next track'
				showStatus
				break ;;
			("prev") cecho "Going to previous track."
				osascript -e '
            tell application "Spotify"
                set player position to 0
                previous track
            end tell'
				showStatus
				break ;;
			("replay") cecho "Replaying current track."
				osascript -e 'tell application "Spotify" to set player position to 0'
				break ;;
			("vol") vol=`osascript -e 'tell application "Spotify" to sound volume as integer'` 
				if [[ $2 = "" || $2 = "show" ]]
				then
					cecho "Current Spotify volume level is $vol."
					break
				elif [ "$2" = "up" ]
				then
					if [ $vol -le $(( 100-$VOL_INCREMENT )) ]
					then
						newvol=$(( vol+$VOL_INCREMENT )) 
						cecho "Increasing Spotify volume to $newvol."
					else
						newvol=100 
						cecho "Spotify volume level is at max."
					fi
				elif [ "$2" = "down" ]
				then
					if [ $vol -ge $(( $VOL_INCREMENT )) ]
					then
						newvol=$(( vol-$VOL_INCREMENT )) 
						cecho "Reducing Spotify volume to $newvol."
					else
						newvol=0 
						cecho "Spotify volume level is at min."
					fi
				elif [[ $2 =~ ^[0-9]+$ ]] && [[ $2 -ge 0 && $2 -le 100 ]]
				then
					newvol=$2 
					cecho "Setting Spotify volume level to $newvol"
				else
					echo "Improper use of 'vol' command"
					echo "The 'vol' command should be used as follows:"
					echo "  vol up                       # Increases the volume by $VOL_INCREMENT%."
					echo "  vol down                     # Decreases the volume by $VOL_INCREMENT%."
					echo "  vol [amount]                 # Sets the volume to an amount between 0 and 100."
					echo "  vol                          # Shows the current Spotify volume."
					return 1
				fi
				osascript -e "tell application \"Spotify\" to set sound volume to $newvol"
				break ;;
			("toggle") if [ "$2" = "shuffle" ]
				then
					osascript -e 'tell application "Spotify" to set shuffling to not shuffling'
					curr=`osascript -e 'tell application "Spotify" to shuffling'` 
					cecho "Spotify shuffling set to $curr"
				elif [ "$2" = "repeat" ]
				then
					osascript -e 'tell application "Spotify" to set repeating to not repeating'
					curr=`osascript -e 'tell application "Spotify" to repeating'` 
					cecho "Spotify repeating set to $curr"
				fi
				break ;;
			("status") if [ $# != 1 ]
				then
					case $2 in
						("artist") showArtist
							break ;;
						("album") showAlbum
							break ;;
						("track") showTrack
							break ;;
					esac
				else
					showStatus
				fi
				break ;;
			("info") info=`osascript -e 'tell application "Spotify"
                set durSec to (duration of current track / 1000)
                set tM to (round (durSec / 60) rounding down) as text
                if length of ((durSec mod 60 div 1) as text) is greater than 1 then
                    set tS to (durSec mod 60 div 1) as text
                else
                    set tS to ("0" & (durSec mod 60 div 1)) as text
                end if
                set myTime to tM as text & "min " & tS as text & "s"
                set pos to player position
                set nM to (round (pos / 60) rounding down) as text
                if length of ((round (pos mod 60) rounding down) as text) is greater than 1 then
                    set nS to (round (pos mod 60) rounding down) as text
                else
                    set nS to ("0" & (round (pos mod 60) rounding down)) as text
                end if
                set nowAt to nM as text & "min " & nS as text & "s"
                set info to "" & "\nArtist:         " & artist of current track
                set info to info & "\nTrack:          " & name of current track
                set info to info & "\nAlbum Artist:   " & album artist of current track
                set info to info & "\nAlbum:          " & album of current track
                set info to info & "\nSeconds:        " & durSec
                set info to info & "\nSeconds played: " & pos
                set info to info & "\nDuration:       " & mytime
                set info to info & "\nNow at:         " & nowAt
                set info to info & "\nPlayed Count:   " & played count of current track
                set info to info & "\nTrack Number:   " & track number of current track
                set info to info & "\nPopularity:     " & popularity of current track
                set info to info & "\nId:             " & id of current track
                set info to info & "\nSpotify URL:    " & spotify url of current track
                set info to info & "\nArtwork:        " & artwork url of current track
                set info to info & "\nPlayer:         " & player state
                set info to info & "\nVolume:         " & sound volume
                set info to info & "\nShuffle:        " & shuffling
                set info to info & "\nRepeating:      " & repeating
            end tell
            return info'` 
				cecho "$info"
				break ;;
			("share") uri=`osascript -e 'tell application "Spotify" to spotify url of current track'` 
				remove='spotify:track:' 
				url=${uri#$remove} 
				url="https://open.spotify.com/track/$url" 
				if [ "$2" = "" ]
				then
					cecho "Spotify URL: $url"
					cecho "Spotify URI: $uri"
					echo "To copy the URL or URI to your clipboard, use:"
					echo "\`spotify share url\` or"
					echo "\`spotify share uri\` respectively."
				elif [ "$2" = "url" ]
				then
					cecho "Spotify URL: $url"
					echo -n $url | pbcopy
				elif [ "$2" = "uri" ]
				then
					cecho "Spotify URI: $uri"
					echo -n $uri | pbcopy
				fi
				break ;;
			("pos") cecho "Adjusting Spotify play position."
				osascript -e "tell application \"Spotify\" to set player position to $2"
				break ;;
			("help") showHelp
				break ;;
			(*) showHelp
				return 1 ;;
		esac
	done
}
svn_prompt_info () {
	return 1
}
ta () {
	if [[ -z $1 ]] || [[ ${1:0:1} == '-' ]]
	then
		tmux attach "$@"
	else
		tmux attach -t "$@"
	fi
}
tab () {
	local command="cd \\\"$PWD\\\"; clear" 
	(( $# > 0 )) && command="${command}; $*" 
	local the_app=$(_omz_macos_get_frontmost_app) 
	if [[ "$the_app" == 'Terminal' ]]
	then
		osascript > /dev/null <<EOF
      tell application "System Events"
        tell process "Terminal" to keystroke "t" using command down
      end tell
      tell application "Terminal" to do script "${command}" in front window
EOF
	elif [[ "$the_app" == 'iTerm' ]]
	then
		osascript <<EOF
      tell application "iTerm"
        set current_terminal to current terminal
        tell current_terminal
          launch session "Default Session"
          set current_session to current session
          tell current_session
            write text "${command}"
          end tell
        end tell
      end tell
EOF
	elif [[ "$the_app" == 'iTerm2' ]]
	then
		osascript <<EOF
      tell application "iTerm2"
        tell current window
          create tab with default profile
          tell current session to write text "${command}"
        end tell
      end tell
EOF
	elif [[ "$the_app" == 'Hyper' ]]
	then
		osascript > /dev/null <<EOF
      tell application "System Events"
        tell process "Hyper" to keystroke "t" using command down
      end tell
      delay 1
      tell application "System Events"
        keystroke "${command}"
        key code 36  #(presses enter)
      end tell
EOF
	elif [[ "$the_app" == 'Tabby' ]]
	then
		osascript > /dev/null <<EOF
      tell application "System Events"
        tell process "Tabby" to keystroke "t" using command down
      end tell
EOF
	elif [[ "$the_app" == 'ghostty' ]]
	then
		osascript > /dev/null <<EOF
      tell application "System Events"
        tell process "Ghostty" to keystroke "t" using command down
      end tell
EOF
	else
		echo "$0: unsupported terminal app: $the_app" >&2
		return 1
	fi
}
tad () {
	if [[ -z $1 ]] || [[ ${1:0:1} == '-' ]]
	then
		tmux attach -d "$@"
	else
		tmux attach -d -t "$@"
	fi
}
take () {
	if [[ $1 =~ ^(https?|ftp).*\.(tar\.(gz|bz2|xz)|tgz)$ ]]
	then
		takeurl "$1"
	elif [[ $1 =~ ^(https?|ftp).*\.(zip)$ ]]
	then
		takezip "$1"
	elif [[ $1 =~ ^([A-Za-z0-9]\+@|https?|git|ssh|ftps?|rsync).*\.git/?$ ]]
	then
		takegit "$1"
	else
		takedir "$@"
	fi
}
takedir () {
	mkdir -p $@ && cd ${@:$#}
}
takegit () {
	git clone "$1"
	cd "$(basename ${1%%.git})"
}
takeurl () {
	local data thedir
	data="$(mktemp)" 
	curl -L "$1" > "$data"
	tar xf "$data"
	thedir="$(tar tf "$data" | head -n 1)" 
	rm "$data"
	cd "$thedir"
}
takezip () {
	local data thedir
	data="$(mktemp)" 
	curl -L "$1" > "$data"
	unzip "$data" -d "./"
	thedir="$(unzip -l "$data" | awk 'NR==4 {print $4}' | sed 's/\/.*//')" 
	rm "$data"
	cd "$thedir"
}
tf_prompt_info () {
	return 1
}
title () {
	setopt localoptions nopromptsubst
	[[ -n "${INSIDE_EMACS:-}" && "$INSIDE_EMACS" != vterm ]] && return
	: ${2=$1}
	case "$TERM" in
		(cygwin | xterm* | putty* | rxvt* | konsole* | ansi | mlterm* | alacritty* | st* | foot* | contour* | wezterm*) print -Pn "\e]2;${2:q}\a"
			print -Pn "\e]1;${1:q}\a" ;;
		(screen* | tmux*) print -Pn "\ek${1:q}\e\\" ;;
		(*) if [[ "$TERM_PROGRAM" == "iTerm.app" ]]
			then
				print -Pn "\e]2;${2:q}\a"
				print -Pn "\e]1;${1:q}\a"
			else
				if (( ${+terminfo[fsl]} && ${+terminfo[tsl]} ))
				then
					print -Pn "${terminfo[tsl]}$1${terminfo[fsl]}"
				fi
			fi ;;
	esac
}
tkss () {
	if [[ -z $1 ]] || [[ ${1:0:1} == '-' ]]
	then
		tmux kill-session "$@"
	else
		tmux kill-session -t "$@"
	fi
}
try_alias_value () {
	alias_value "$1" || echo "$1"
}
ts () {
	if [[ -z $1 ]] || [[ ${1:0:1} == '-' ]]
	then
		tmux new-session "$@"
	else
		tmux new-session -s "$@"
	fi
}
unbundled_annotate () {
	"annotate" "$@"
}
unbundled_cap () {
	"cap" "$@"
}
unbundled_capify () {
	"capify" "$@"
}
unbundled_cucumber () {
	"cucumber" "$@"
}
unbundled_foodcritic () {
	"foodcritic" "$@"
}
unbundled_guard () {
	"guard" "$@"
}
unbundled_hanami () {
	"hanami" "$@"
}
unbundled_irb () {
	"irb" "$@"
}
unbundled_jekyll () {
	"jekyll" "$@"
}
unbundled_kitchen () {
	"kitchen" "$@"
}
unbundled_knife () {
	"knife" "$@"
}
unbundled_middleman () {
	"middleman" "$@"
}
unbundled_nanoc () {
	"nanoc" "$@"
}
unbundled_pry () {
	"pry" "$@"
}
unbundled_puma () {
	"puma" "$@"
}
unbundled_rackup () {
	"rackup" "$@"
}
unbundled_rainbows () {
	"rainbows" "$@"
}
unbundled_rake () {
	"rake" "$@"
}
unbundled_rspec () {
	"rspec" "$@"
}
unbundled_rubocop () {
	"rubocop" "$@"
}
unbundled_shotgun () {
	"shotgun" "$@"
}
unbundled_sidekiq () {
	"sidekiq" "$@"
}
unbundled_spec () {
	"spec" "$@"
}
unbundled_spork () {
	"spork" "$@"
}
unbundled_spring () {
	"spring" "$@"
}
unbundled_strainer () {
	"strainer" "$@"
}
unbundled_tailor () {
	"tailor" "$@"
}
unbundled_taps () {
	"taps" "$@"
}
unbundled_thin () {
	"thin" "$@"
}
unbundled_thor () {
	"thor" "$@"
}
unbundled_unicorn () {
	"unicorn" "$@"
}
unbundled_unicorn_rails () {
	"unicorn_rails" "$@"
}
uninstall_oh_my_zsh () {
	command env ZSH="$ZSH" sh "$ZSH/tools/uninstall.sh"
}
up-line-or-beginning-search () {
	# undefined
	builtin autoload -XU
}
upgrade_oh_my_zsh () {
	echo "${fg[yellow]}Note: \`$0\` is deprecated. Use \`omz update\` instead.$reset_color" >&2
	omz update
}
url-quote-magic () {
	# undefined
	builtin autoload -XUz
}
vi_mode_prompt_info () {
	return 1
}
virtualenv_prompt_info () {
	return 1
}
vncviewer () {
	open vnc://$@
}
vrun () {
	if [[ -z "$1" ]]
	then
		local name
		for name in $PYTHON_VENV_NAMES
		do
			local venvpath="${name:P}" 
			if [[ -d "$venvpath" ]]
			then
				vrun "$name"
				return $?
			fi
		done
		echo "Error: no virtual environment found in current directory" >&2
	fi
	local name="${1:-$PYTHON_VENV_NAME}" 
	local venvpath="${name:P}" 
	if [[ ! -d "$venvpath" ]]
	then
		echo "Error: no such venv in current directory: $name" >&2
		return 1
	fi
	if [[ ! -f "${venvpath}/bin/activate" ]]
	then
		echo "Error: '${name}' is not a proper virtual environment" >&2
		return 1
	fi
	. "${venvpath}/bin/activate" || return $?
	echo "Activated virtual environment ${name}"
}
vsc () {
	if (( $# ))
	then
		$VSCODE $@
	else
		$VSCODE .
	fi
}
vsplit_tab () {
	local command="cd \\\"$PWD\\\"; clear" 
	(( $# > 0 )) && command="${command}; $*" 
	local the_app=$(_omz_macos_get_frontmost_app) 
	if [[ "$the_app" == 'iTerm' ]]
	then
		osascript <<EOF
      -- tell application "iTerm" to activate
      tell application "System Events"
        tell process "iTerm"
          tell menu item "Split Vertically With Current Profile" of menu "Shell" of menu bar item "Shell" of menu bar 1
            click
          end tell
        end tell
        keystroke "${command} \n"
      end tell
EOF
	elif [[ "$the_app" == 'iTerm2' ]]
	then
		osascript <<EOF
      tell application "iTerm2"
        tell current session of first window
          set newSession to (split vertically with same profile)
          tell newSession
            write text "${command}"
            select
          end tell
        end tell
      end tell
EOF
	elif [[ "$the_app" == 'Hyper' ]]
	then
		osascript > /dev/null <<EOF
    tell application "System Events"
      tell process "Hyper"
        tell menu item "Split Vertically" of menu "Shell" of menu bar 1
          click
        end tell
      end tell
      delay 1
      keystroke "${command} \n"
    end tell
EOF
	elif [[ "$the_app" == 'Tabby' ]]
	then
		osascript > /dev/null <<EOF
      tell application "System Events"
        tell process "Tabby" to keystroke "D" using command down
      end tell
EOF
	elif [[ "$the_app" == 'ghostty' ]]
	then
		osascript > /dev/null <<EOF
      tell application "System Events"
        tell process "Ghostty" to keystroke "D" using command down
      end tell
EOF
	else
		echo "$0: unsupported terminal app: $the_app" >&2
		return 1
	fi
}
work_in_progress () {
	command git -c log.showSignature=false log -n 1 2> /dev/null | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv} -q -- "--wip--" && echo "WIP!!"
}
zle-line-finish () {
	echoti rmkx
}
zle-line-init () {
	echoti smkx
}
zrecompile () {
	setopt localoptions extendedglob noshwordsplit noksharrays
	local opt check quiet zwc files re file pre ret map tmp mesg pats
	tmp=() 
	while getopts ":tqp" opt
	do
		case $opt in
			(t) check=yes  ;;
			(q) quiet=yes  ;;
			(p) pats=yes  ;;
			(*) if [[ -n $pats ]]
				then
					tmp=($tmp $OPTARG) 
				else
					print -u2 zrecompile: bad option: -$OPTARG
					return 1
				fi ;;
		esac
	done
	shift OPTIND-${#tmp}-1
	if [[ -n $check ]]
	then
		ret=1 
	else
		ret=0 
	fi
	if [[ -n $pats ]]
	then
		local end num
		while (( $# ))
		do
			end=$argv[(i)--] 
			if [[ end -le $# ]]
			then
				files=($argv[1,end-1]) 
				shift end
			else
				files=($argv) 
				argv=() 
			fi
			tmp=() 
			map=() 
			OPTIND=1 
			while getopts :MR opt $files
			do
				case $opt in
					([MR]) map=(-$opt)  ;;
					(*) tmp=($tmp $files[OPTIND])  ;;
				esac
			done
			shift OPTIND-1 files
			(( $#files )) || continue
			files=($files[1] ${files[2,-1]:#*(.zwc|~)}) 
			(( $#files )) || continue
			zwc=${files[1]%.zwc}.zwc 
			shift 1 files
			(( $#files )) || files=(${zwc%.zwc}) 
			if [[ -f $zwc ]]
			then
				num=$(zcompile -t $zwc | wc -l) 
				if [[ num-1 -ne $#files ]]
				then
					re=yes 
				else
					re= 
					for file in $files
					do
						if [[ $file -nt $zwc ]]
						then
							re=yes 
							break
						fi
					done
				fi
			else
				re=yes 
			fi
			if [[ -n $re ]]
			then
				if [[ -n $check ]]
				then
					[[ -z $quiet ]] && print $zwc needs re-compilation
					ret=0 
				else
					[[ -z $quiet ]] && print -n "re-compiling ${zwc}: "
					if [[ -z "$quiet" ]] && {
							[[ ! -f $zwc ]] || mv -f $zwc ${zwc}.old
						} && zcompile $map $tmp $zwc $files
					then
						print succeeded
					elif ! {
							{
								[[ ! -f $zwc ]] || mv -f $zwc ${zwc}.old
							} && zcompile $map $tmp $zwc $files 2> /dev/null
						}
					then
						[[ -z $quiet ]] && print "re-compiling ${zwc}: failed"
						ret=1 
					fi
				fi
			fi
		done
		return ret
	fi
	if (( $# ))
	then
		argv=(${^argv}/*.zwc(ND) ${^argv}.zwc(ND) ${(M)argv:#*.zwc}) 
	else
		argv=(${^fpath}/*.zwc(ND) ${^fpath}.zwc(ND) ${(M)fpath:#*.zwc}) 
	fi
	argv=(${^argv%.zwc}.zwc) 
	for zwc
	do
		files=(${(f)"$(zcompile -t $zwc)"}) 
		if [[ $files[1] = *\(mapped\)* ]]
		then
			map=-M 
			mesg='succeeded (old saved)' 
		else
			map=-R 
			mesg=succeeded 
		fi
		if [[ $zwc = */* ]]
		then
			pre=${zwc%/*}/ 
		else
			pre= 
		fi
		if [[ $files[1] != *$ZSH_VERSION ]]
		then
			re=yes 
		else
			re= 
		fi
		files=(${pre}${^files[2,-1]:#/*} ${(M)files[2,-1]:#/*}) 
		[[ -z $re ]] && for file in $files
		do
			if [[ $file -nt $zwc ]]
			then
				re=yes 
				break
			fi
		done
		if [[ -n $re ]]
		then
			if [[ -n $check ]]
			then
				[[ -z $quiet ]] && print $zwc needs re-compilation
				ret=0 
			else
				[[ -z $quiet ]] && print -n "re-compiling ${zwc}: "
				tmp=(${^files}(N)) 
				if [[ $#tmp -ne $#files ]]
				then
					[[ -z $quiet ]] && print 'failed (missing files)'
					ret=1 
				else
					if [[ -z "$quiet" ]] && mv -f $zwc ${zwc}.old && zcompile $map $zwc $files
					then
						print $mesg
					elif ! {
							mv -f $zwc ${zwc}.old && zcompile $map $zwc $files 2> /dev/null
						}
					then
						[[ -z $quiet ]] && print "re-compiling ${zwc}: failed"
						ret=1 
					fi
				fi
			fi
		fi
	done
	return ret
}
zsh-pip-cache-packages () {
	if [[ ! -d ${ZSH_PIP_CACHE_FILE:h} ]]
	then
		mkdir -p ${ZSH_PIP_CACHE_FILE:h}
	fi
	if [[ ! -f $ZSH_PIP_CACHE_FILE ]]
	then
		echo -n "(...caching package index...)"
		tmp_cache=/tmp/zsh_tmp_cache 
		touch $tmp_cache
		for index in $ZSH_PIP_INDEXES
		do
			curl -L $index 2> /dev/null | zsh-pip-clean-packages >> $tmp_cache
		done
		sort $tmp_cache | uniq | tr '\n' ' ' > $ZSH_PIP_CACHE_FILE
		rm $tmp_cache
	fi
}
zsh-pip-clean-packages () {
	sed -n '/<a href/ s/.*>\([^<]\{1,\}\).*/\1/p'
}
zsh-pip-clear-cache () {
	rm $ZSH_PIP_CACHE_FILE
	unset piplist
}
zsh-pip-test-clean-packages () {
	local expected
	local actual
	expected="0x10c-asm
1009558_nester" 
	actual=$(echo -n "<html><head><title>Simple Index</title><meta name=\"api-version\" value=\"2\" /></head><body>
<a href='0x10c-asm'>0x10c-asm</a><br/>
<a href='1009558_nester'>1009558_nester</a><br/>
</body></html>" | zsh-pip-clean-packages) 
	if [[ $actual != $expected ]]
	then
		echo -e "python's simple index is broken:\n$actual\n  !=\n$expected"
	else
		echo "python's simple index is fine"
	fi
	actual=$(echo -n '<html>
  <head>
    <title>Simple Package Index</title>
  </head>
  <body>
    <a href="0x10c-asm">0x10c-asm</a><br/>
    <a href="1009558_nester">1009558_nester</a><br/>
</body></html>' | zsh-pip-clean-packages) 
	if [[ $actual != $expected ]]
	then
		echo -e "the djangopypi2 index is broken:\n$actual\n  !=\n$expected"
	else
		echo "the djangopypi2 index is fine"
	fi
}
zsh_stats () {
	fc -l 1 | awk '{ CMD[$2]++; count++; } END { for (a in CMD) print CMD[a] " " CMD[a]*100/count "% " a }' | grep -v "./" | sort -nr | head -n 20 | column -c3 -s " " -t | nl
}
# Shell Options
setopt alwaystoend
setopt autocd
setopt autopushd
setopt completeinword
setopt extendedhistory
setopt noflowcontrol
setopt nohashdirs
setopt histexpiredupsfirst
setopt histignoredups
setopt histignorespace
setopt histverify
setopt interactivecomments
setopt login
setopt longlistjobs
setopt promptsubst
setopt pushdignoredups
setopt pushdminus
setopt sharehistory
# Aliases
alias -- -='cd -'
alias -- ..='cd ..'
alias -- ...='cd ../..'
alias -- ....='cd ../../..'
alias -- .....=../../../..
alias -- ......=../../../../..
alias -- 1='cd -1'
alias -- 2='cd -2'
alias -- 3='cd -3'
alias -- 4='cd -4'
alias -- 5='cd -5'
alias -- 6='cd -6'
alias -- 7='cd -7'
alias -- 8='cd -8'
alias -- 9='cd -9'
alias -- RED='RAILS_ENV=development'
alias -- REP='RAILS_ENV=production'
alias -- RET='RAILS_ENV=test'
alias -- _='sudo '
alias -- aliases='$EDITOR ~/.aliases'
alias -- annotate=bundled_annotate
alias -- axbrew='arch -x86_64 /usr/local/homebrew/bin/brew'
alias -- ba='bundle add'
alias -- bci='brew info --cask'
alias -- bcin='brew install --cask'
alias -- bck='bundle check'
alias -- bcl='brew list --cask'
alias -- bcn='bundle clean'
alias -- bco='brew outdated --cask'
alias -- bcrin='brew reinstall --cask'
alias -- bcubc='brew upgrade --cask && brew cleanup'
alias -- bcubo='brew update && brew outdated --cask'
alias -- bcup='brew upgrade --cask'
alias -- be='bundle exec'
alias -- bfu='brew upgrade --formula'
alias -- bi=bundle_install
alias -- bin/rake='noglob bin/rake'
alias -- bl='bundle list'
alias -- bo='bundle open'
alias -- bout='bundle outdated'
alias -- bp='bundle package'
alias -- brake='noglob bundle exec rake'
alias -- brewp='brew pin'
alias -- brewsp='brew list --pinned'
alias -- bsl='brew services list'
alias -- bsoff='brew services stop'
alias -- bsoffa='bsoff --all'
alias -- bson='brew services start'
alias -- bsona='bson --all'
alias -- bsr='brew services run'
alias -- bsra='bsr --all'
alias -- bu='bundle update'
alias -- bubo='brew update && brew outdated'
alias -- bubu='bubo && bup'
alias -- bubug='bubo && bugbc'
alias -- bugbc='brew upgrade --greedy && brew cleanup'
alias -- bup='brew upgrade'
alias -- buz='brew uninstall --zap'
alias -- cap=bundled_cap
alias -- capify=bundled_capify
alias -- cat=bat
alias -- ccat=colorize_cat
alias -- claude=/Users/bmc/.claude/local/claude
alias -- cless=colorize_less
alias -- cm=chezmoi
alias -- cma='chezmoi apply'
alias -- cmd='chezmoi diff'
alias -- cme='chezmoi edit'
alias -- cmra='chezmoi re-add'
alias -- cp='cp -i'
alias -- cucumber=bundled_cucumber
alias -- d=docker
alias -- dbl='docker build'
alias -- dc=docker-compose
alias -- dcin='docker container inspect'
alias -- dcls='docker container ls'
alias -- dclsa='docker container ls -a'
alias -- devlog='tail -f log/development.log'
alias -- df='df -h'
alias -- di='docker images'
alias -- dib='docker image build'
alias -- dii='docker image inspect'
alias -- dils='docker image ls'
alias -- dipru='docker image prune -a'
alias -- dipu='docker image push'
alias -- dirm='docker image rm'
alias -- dit='docker image tag'
alias -- dlo='docker container logs'
alias -- dnc='docker network create'
alias -- dncn='docker network connect'
alias -- dndcn='docker network disconnect'
alias -- dni='docker network inspect'
alias -- dnls='docker network ls'
alias -- dnrm='docker network rm'
alias -- dpo='docker container port'
alias -- dps='docker ps'
alias -- dpsa='docker ps -a'
alias -- dpu='docker pull'
alias -- dr='docker container run'
alias -- drit='docker container run -it'
alias -- drm='docker container rm'
alias -- drm!='docker container rm -f'
alias -- drs='docker container restart'
alias -- dst='docker container start'
alias -- dsta='docker stop $(docker ps -q)'
alias -- dstp='docker container stop'
alias -- dsts='docker stats'
alias -- dtop='docker top'
alias -- du='du -h'
alias -- dvi='docker volume inspect'
alias -- dvls='docker volume ls'
alias -- dvprune='docker volume prune'
alias -- dxc='docker container exec'
alias -- dxcit='docker container exec -it'
alias -- egrep='grep -E'
alias -- fabric=fabric-ai
alias -- fgrep='grep -F'
alias -- find=fd
alias -- fmns='foreman start'
alias -- foodcritic=bundled_foodcritic
alias -- free='free -h'
alias -- g=git
alias -- ga='git add'
alias -- gaa='git add --all'
alias -- gam=/Users/bmc/bin/gamadv-xtd3/gam
alias -- gama='git am --abort'
alias -- gamc='git am --continue'
alias -- gams='git am --skip'
alias -- gamscp='git am --show-current-patch'
alias -- gap='git apply'
alias -- gapa='git add --patch'
alias -- gapt='git apply --3way'
alias -- gau='git add --update'
alias -- gav='git add --verbose'
alias -- gb='git branch'
alias -- gbD='git branch --delete --force'
alias -- gba='git branch --all'
alias -- gbd='git branch --delete'
alias -- gbg='LANG=C git branch -vv | grep ": gone\]"'
alias -- gbgD='LANG=C git branch --no-color -vv | grep ": gone\]" | cut -c 3- | awk '\''{print $1}'\'' | xargs git branch -D'
alias -- gbgd='LANG=C git branch --no-color -vv | grep ": gone\]" | cut -c 3- | awk '\''{print $1}'\'' | xargs git branch -d'
alias -- gbl='git blame -w'
alias -- gbm='git branch --move'
alias -- gbnm='git branch --no-merged'
alias -- gbr='git branch --remote'
alias -- gbs='git bisect'
alias -- gbsb='git bisect bad'
alias -- gbsg='git bisect good'
alias -- gbsn='git bisect new'
alias -- gbso='git bisect old'
alias -- gbsr='git bisect reset'
alias -- gbss='git bisect start'
alias -- gc='git commit'
alias -- gc!='git commit --verbose --amend'
alias -- gcB='git checkout -B'
alias -- gca='git commit -a'
alias -- gca!='git commit --verbose --all --amend'
alias -- gcam='git commit --all --message'
alias -- gcan!='git commit --verbose --all --no-edit --amend'
alias -- gcann!='git commit --verbose --all --date=now --no-edit --amend'
alias -- gcans!='git commit --verbose --all --signoff --no-edit --amend'
alias -- gcas='git commit --all --signoff'
alias -- gcasm='git commit --all --signoff --message'
alias -- gcb='git checkout -b'
alias -- gcd='git checkout $(git_develop_branch)'
alias -- gcf='git config --list'
alias -- gcfu='git commit --fixup'
alias -- gcl='git clone --recurse-submodules'
alias -- gclean='git clean --interactive -d'
alias -- gclf='git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules'
alias -- gcm='git commit -m'
alias -- gcmsg='git commit --message'
alias -- gcn='git commit --verbose --no-edit'
alias -- gcn!='git commit --verbose --no-edit --amend'
alias -- gco='git checkout'
alias -- gcor='git checkout --recurse-submodules'
alias -- gcount='git shortlog --summary --numbered'
alias -- gcp='git cherry-pick'
alias -- gcpa='git cherry-pick --abort'
alias -- gcpc='git cherry-pick --continue'
alias -- gcs='git commit --gpg-sign'
alias -- gcsm='git commit --signoff --message'
alias -- gcss='git commit --gpg-sign --signoff'
alias -- gcssm='git commit --gpg-sign --signoff --message'
alias -- gd='git diff'
alias -- gdca='git diff --cached'
alias -- gdct='git describe --tags $(git rev-list --tags --max-count=1)'
alias -- gdcw='git diff --cached --word-diff'
alias -- gds='git diff --staged'
alias -- gdt='git diff-tree --no-commit-id --name-only -r'
alias -- gdup='git diff @{upstream}'
alias -- gdw='git diff --word-diff'
alias -- geca='gem cert --add'
alias -- gecb='gem cert --build'
alias -- geclup='gem cleanup -n'
alias -- gecr='gem cert --remove'
alias -- gegi='gem generate_index'
alias -- geh='gem help'
alias -- gei='gem info'
alias -- geiall='gem info --all'
alias -- gein='gem install'
alias -- gel='gem lock'
alias -- geli='gem list'
alias -- geo='gem open'
alias -- geoe='gem open -e'
alias -- geun='gem uninstall'
alias -- gf='git fetch'
alias -- gfa='git fetch --all --tags --prune --jobs=10'
alias -- gfg='git ls-files | grep'
alias -- gfo='git fetch origin'
alias -- gg='git gui citool'
alias -- gga='git gui citool --amend'
alias -- ggpull='git pull origin "$(git_current_branch)"'
alias -- ggpur=ggu
alias -- ggpush='git push origin "$(git_current_branch)"'
alias -- ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
alias -- ghh='git help'
alias -- gignore='git update-index --assume-unchanged'
alias -- gignored='git ls-files -v | grep "^[[:lower:]]"'
alias -- git-svn-dcommit-push='git svn dcommit && git push github $(git_main_branch):svntrunk'
alias -- gk='\gitk --all --branches &!'
alias -- gke='\gitk --all $(git log --walk-reflogs --pretty=%h) &!'
alias -- gl='git log --oneline'
alias -- gla='git log --oneline --all --graph'
alias -- glg='git log --stat'
alias -- glgg='git log --graph'
alias -- glgga='git log --graph --decorate --all'
alias -- glgm='git log --graph --max-count=10'
alias -- glgp='git log --stat --patch'
alias -- glo='git log --oneline --decorate'
alias -- glod='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset"'
alias -- glods='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'
alias -- glog='git log --oneline --decorate --graph'
alias -- gloga='git log --oneline --decorate --graph --all'
alias -- glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias -- glola='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
alias -- glols='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'
alias -- glp=_git_log_prettily
alias -- gluc='git pull upstream $(git_current_branch)'
alias -- glum='git pull upstream $(git_main_branch)'
alias -- gm='git merge'
alias -- gma='git merge --abort'
alias -- gmc='git merge --continue'
alias -- gmff='git merge --ff-only'
alias -- gmom='git merge origin/$(git_main_branch)'
alias -- gms='git merge --squash'
alias -- gmtl='git mergetool --no-prompt'
alias -- gmtlvim='git mergetool --no-prompt --tool=vimdiff'
alias -- gmum='git merge upstream/$(git_main_branch)'
alias -- gp='git push'
alias -- gpd='git push --dry-run'
alias -- gpf='git push --force-with-lease --force-if-includes'
alias -- gpf!='git push --force'
alias -- gpl='git pull'
alias -- gpoat='git push origin --all && git push origin --tags'
alias -- gpod='git push origin --delete'
alias -- gpr='git pull --rebase'
alias -- gpra='git pull --rebase --autostash'
alias -- gprav='git pull --rebase --autostash -v'
alias -- gpristine='git reset --hard && git clean --force -dfx'
alias -- gprom='git pull --rebase origin $(git_main_branch)'
alias -- gpromi='git pull --rebase=interactive origin $(git_main_branch)'
alias -- gprum='git pull --rebase upstream $(git_main_branch)'
alias -- gprumi='git pull --rebase=interactive upstream $(git_main_branch)'
alias -- gprv='git pull --rebase -v'
alias -- gpsup='git push --set-upstream origin $(git_current_branch)'
alias -- gpsupf='git push --set-upstream origin $(git_current_branch) --force-with-lease --force-if-includes'
alias -- gpu='git push upstream'
alias -- gpv='git push --verbose'
alias -- gr='git rebase'
alias -- gra='git remote add'
alias -- grb='git rebase'
alias -- grba='git rebase --abort'
alias -- grbc='git rebase --continue'
alias -- grbd='git rebase $(git_develop_branch)'
alias -- grbi='git rebase --interactive'
alias -- grbm='git rebase $(git_main_branch)'
alias -- grbo='git rebase --onto'
alias -- grbom='git rebase origin/$(git_main_branch)'
alias -- grbs='git rebase --skip'
alias -- grbum='git rebase upstream/$(git_main_branch)'
alias -- grep=rg
alias -- grev='git revert'
alias -- greva='git revert --abort'
alias -- grevc='git revert --continue'
alias -- grf='git reflog'
alias -- grh='git reset'
alias -- grhh='git reset --hard'
alias -- grhk='git reset --keep'
alias -- grhs='git reset --soft'
alias -- grm='git rm'
alias -- grmc='git rm --cached'
alias -- grmv='git remote rename'
alias -- groh='git reset origin/$(git_current_branch) --hard'
alias -- grrm='git remote remove'
alias -- grs='git restore'
alias -- grset='git remote set-url'
alias -- grss='git restore --source'
alias -- grst='git restore --staged'
alias -- grt='cd "$(git rev-parse --show-toplevel || echo .)"'
alias -- gru='git reset --'
alias -- grup='git remote update'
alias -- grv='git remote --verbose'
alias -- gs='git status'
alias -- gsb='git status --short --branch'
alias -- gsd='git svn dcommit'
alias -- gsh='git show'
alias -- gsi='git submodule init'
alias -- gsl='git stash list'
alias -- gsp='git stash pop'
alias -- gsps='git show --pretty=short --show-signature'
alias -- gsr='git svn rebase'
alias -- gss='git stash save'
alias -- gst='git status'
alias -- gsta='git stash push'
alias -- gstaa='git stash apply'
alias -- gstall='git stash --all'
alias -- gstc='git stash clear'
alias -- gstd='git stash drop'
alias -- gstl='git stash list'
alias -- gstp='git stash pop'
alias -- gsts='git stash show --patch'
alias -- gstu='gsta --include-untracked'
alias -- gsu='git submodule update'
alias -- gsw='git switch'
alias -- gswc='git switch --create'
alias -- gswd='git switch $(git_develop_branch)'
alias -- gswm='git switch $(git_main_branch)'
alias -- gta='git tag --annotate'
alias -- gtl='gtl(){ git tag --sort=-v:refname -n --list "${1}*" }; noglob gtl'
alias -- gts='git tag --sign'
alias -- gtv='git tag | sort -V'
alias -- guard=bundled_guard
alias -- gunignore='git update-index --no-assume-unchanged'
alias -- gunwip='git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'
alias -- gup=$'\n    print -Pu2 "%F{yellow}[oh-my-zsh] \'%F{red}gup%F{yellow}\' is a deprecated alias, using \'%F{green}gpr%F{yellow}\' instead.%f"\n    gpr'
alias -- gupa=$'\n    print -Pu2 "%F{yellow}[oh-my-zsh] \'%F{red}gupa%F{yellow}\' is a deprecated alias, using \'%F{green}gpra%F{yellow}\' instead.%f"\n    gpra'
alias -- gupav=$'\n    print -Pu2 "%F{yellow}[oh-my-zsh] \'%F{red}gupav%F{yellow}\' is a deprecated alias, using \'%F{green}gprav%F{yellow}\' instead.%f"\n    gprav'
alias -- gupom=$'\n    print -Pu2 "%F{yellow}[oh-my-zsh] \'%F{red}gupom%F{yellow}\' is a deprecated alias, using \'%F{green}gprom%F{yellow}\' instead.%f"\n    gprom'
alias -- gupomi=$'\n    print -Pu2 "%F{yellow}[oh-my-zsh] \'%F{red}gupomi%F{yellow}\' is a deprecated alias, using \'%F{green}gpromi%F{yellow}\' instead.%f"\n    gpromi'
alias -- gupv=$'\n    print -Pu2 "%F{yellow}[oh-my-zsh] \'%F{red}gupv%F{yellow}\' is a deprecated alias, using \'%F{green}gprv%F{yellow}\' instead.%f"\n    gprv'
alias -- gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias -- gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'
alias -- gwipe='git reset --hard && git clean --force -df'
alias -- gwt='git worktree'
alias -- gwta='git worktree add'
alias -- gwtls='git worktree list'
alias -- gwtmv='git worktree move'
alias -- gwtrm='git worktree remove'
alias -- h=history
alias -- hanami=bundled_hanami
alias -- hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
alias -- history=omz_history
alias -- irb=bundled_irb
alias -- j=jobs
alias -- jekyll=bundled_jekyll
alias -- jimweirich=rake
alias -- jsonpp='python -m json.tool'
alias -- kitchen=bundled_kitchen
alias -- knife=bundled_knife
alias -- l='ls -lah'
alias -- la='eza -la --icons'
alias -- ll='eza -l --icons'
alias -- ls='eza --icons'
alias -- lsa='ls -lah'
alias -- md='mkdir -p'
alias -- middleman=bundled_middleman
alias -- mkdir='mkdir -p'
alias -- mv='mv -i'
alias -- nanoc=bundled_nanoc
alias -- path='echo -e ${PATH//:/\\n}'
alias -- ping='ping -c 5'
alias -- pip='noglob pip'
alias -- pipgi='pip freeze | grep'
alias -- pipi='pip install'
alias -- pipir='pip install -r requirements.txt'
alias -- piplo='pip list -o'
alias -- pipreq='pip freeze > requirements.txt'
alias -- pipu='pip install --upgrade'
alias -- pipun='pip uninstall'
alias -- ports='netstat -tulanp'
alias -- prodlog='tail -f log/production.log'
alias -- pry=bundled_pry
alias -- ps=procs
alias -- puma=bundled_puma
alias -- py=python3
alias -- pyfind='find . -name "*.py"'
alias -- pygrep='grep -nr --include="*.py"'
alias -- pyserver='python3 -m http.server'
alias -- rackup=bundled_rackup
alias -- rails=_rails_command
alias -- rainbows=bundled_rainbows
alias -- rake=_rake_command
alias -- rb=ruby
alias -- rc='rails console'
alias -- rcs='rails console --sandbox'
alias -- rd='rails destroy'
alias -- rdb='rails dbconsole'
alias -- rdc='rails db:create'
alias -- rdd='rails db:drop'
alias -- rdm='rails db:migrate'
alias -- rdmd='rails db:migrate:down'
alias -- rdmr='rails db:migrate:redo'
alias -- rdms='rails db:migrate:status'
alias -- rdmtc='rails db:migrate db:test:clone'
alias -- rdmu='rails db:migrate:up'
alias -- rdr='rails db:rollback'
alias -- rdrs='rails db:reset'
alias -- rds='rails db:seed'
alias -- rdsl='rails db:schema:load'
alias -- rdtc='rails db:test:clone'
alias -- rdtp='rails db:test:prepare'
alias -- release='git log $(git describe --tags --abbrev=0)..HEAD --no-merges --oneline'
alias -- reload='source ~/.zshrc'
alias -- rfind='find . -name "*.rb" | xargs grep -n'
alias -- rgen='rails generate'
alias -- rgm='rails generate migration'
alias -- rkdc='rake db:create'
alias -- rkdd='rake db:drop'
alias -- rkdm='rake db:migrate'
alias -- rkdmd='rake db:migrate:down'
alias -- rkdmr='rake db:migrate:redo'
alias -- rkdms='rake db:migrate:status'
alias -- rkdmtc='rake db:migrate db:test:clone'
alias -- rkdmu='rake db:migrate:up'
alias -- rkdr='rake db:rollback'
alias -- rkdrs='rake db:reset'
alias -- rkds='rake db:seed'
alias -- rkdsl='rake db:schema:load'
alias -- rkdtc='rake db:test:clone'
alias -- rkdtp='rake db:test:prepare'
alias -- rklc='rake log:clear'
alias -- rkmd='rake middleware'
alias -- rkn='rake notes'
alias -- rksts='rake stats'
alias -- rkt='rake test'
alias -- rlc='rails log:clear'
alias -- rm='rm -i'
alias -- rmd='rails middleware'
alias -- rn='rails notes'
alias -- rp='rails plugin'
alias -- rr='rails routes'
alias -- rrc='rails routes --controller'
alias -- rre='rails routes --expanded'
alias -- rrg='rails routes --grep'
alias -- rru='rails routes --unused'
alias -- rrun='ruby -e'
alias -- rs='rails server'
alias -- rsb='rails server --bind'
alias -- rsd='rails server --debugger'
alias -- rserver='ruby -run -e httpd . -p 8080'
alias -- rsp='rails server --port'
alias -- rspec=bundled_rspec
alias -- rsts='rails stats'
alias -- rt='rails test'
alias -- rta='rails test:all'
alias -- ru='rails runner'
alias -- rubocop=bundled_rubocop
alias -- run-help=man
alias -- sbrake='noglob sudo bundle exec rake'
alias -- sc='ruby script/console'
alias -- sd='ruby script/server --debugger'
alias -- serve='python -m http.server'
alias -- sg='ruby script/generate'
alias -- sgem='sudo gem'
alias -- shotgun=bundled_shotgun
alias -- showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
alias -- sidekiq=bundled_sidekiq
alias -- sp='ruby script/plugin'
alias -- spec=bundled_spec
alias -- spork=bundled_spork
alias -- spring=bundled_spring
alias -- sr='ruby script/runner'
alias -- srake='noglob sudo rake'
alias -- ssp='ruby script/spec'
alias -- sstat='thin --stats "/thin/stats" start'
alias -- strainer=bundled_strainer
alias -- tailor=bundled_tailor
alias -- taps=bundled_taps
alias -- tds=_tmux_directory_session
alias -- testlog='tail -f log/test.log'
alias -- thin=bundled_thin
alias -- thor=bundled_thor
alias -- tksv='tmux kill-server'
alias -- tl='tmux list-sessions'
alias -- tmux=_zsh_tmux_plugin_run
alias -- tmuxconf='$EDITOR $ZSH_TMUX_CONFIG'
alias -- top=htop
alias -- tree='eza --tree --icons'
alias -- unicorn=bundled_unicorn
alias -- unicorn_rails=bundled_unicorn_rails
alias -- urldecode='python -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1]))"'
alias -- urlencode='python -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]))"'
alias -- vimrc='$EDITOR ~/.vimrc'
alias -- vsca='code --add'
alias -- vscd='code --diff'
alias -- vscde='code --disable-extensions'
alias -- vsced='code --extensions-dir'
alias -- vscg='code --goto'
alias -- vscie='code --install-extension'
alias -- vscl='code --log'
alias -- vscn='code --new-window'
alias -- vscp='code --profile'
alias -- vscr='code --reuse-window'
alias -- vscu='code --user-data-dir'
alias -- vscue='code --uninstall-extension'
alias -- vscv='code --verbose'
alias -- vscw='code --wait'
alias -- which-command=whence
alias -- zshrc='$EDITOR ~/.zshrc'
alias -- '~'='cd ~'
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg='/opt/homebrew/Cellar/ripgrep/14.1.1/bin/rg'
fi
export PATH=/Users/bmc/go/bin\:/opt/homebrew/opt/go/libexec/bin\:/Users/bmc/bin/gamadv-xtd3\:/opt/homebrew/share/google-cloud-sdk/bin\:/usr/local/opt/icu4c/bin\:/usr/local/opt/icu4c/sbin\:/usr/local/opt/python/libexec/bin\:/Users/bmc/.local/bin\:/Users/bmc/.local/share/mise/installs/ruby/3.4.1/bin\:/Users/bmc/.local/share/mise/installs/node/22.15.0/bin\:/Users/bmc/.local/share/mise/installs/python/3.12.0/bin\:/Users/bmc/bin\:/opt/homebrew/bin\:/usr/local/bin\:/usr/local/sbin\:/opt/homebrew/bin\:/opt/homebrew/sbin\:/usr/local/bin\:/System/Cryptexes/App/usr/bin\:/usr/bin\:/bin\:/usr/sbin\:/sbin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin\:/usr/local/MacGPG2/bin\:/Users/bmc/.local/bin
