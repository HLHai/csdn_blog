import sys

try:
	key=sys.argv[1]
	s='select '
	for i in range(int(key)):
		i=i+1
		if i!=1:
			s=s+","
		s=s+str(i)	
		print(s)
except Exception as e:
	print(e)