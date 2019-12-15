from prompt_toolkit import prompt
from prompt_toolkit.styles import Style
from prompt_toolkit import PromptSession
from prompt_toolkit.auto_suggest import AutoSuggestFromHistory
from prompt_toolkit.completion.word_completer import WordCompleter

session = PromptSession()

com=['aa','exitc','see_all_cve','help','see_one_cve','use_cve_poc','use_cve_exp','shodan']

Completer = WordCompleter(com,
                             ignore_case=True)

style = Style.from_dict({
    # User input (default text).
    '':          '#FFA500',

    # Prompt.
    'pound':    '#FFFFFF',
    'path':     '#FFFFFF',
})


message = [
    ('class:path',     '王嘟嘟-blog:'),
    ('class:pound',    '# '),
]


while 1:
	user_input =session.prompt(message,
						style=style,
						auto_suggest=AutoSuggestFromHistory(),
						completer=Completer,
						bottom_toolbar="测试"
						)
	print(user_input)
	if user_input=="exit":
		break