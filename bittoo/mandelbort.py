from Tkinter import *
xa = -2.0; xb = 1.0
ya = -1.5; yb = 1.5

def check(c) :
	z=0;
	for i in range(0,20):
		z = z*z+c;
		if abs(z)>2:
			break;
	if abs(z) >= 2 :
		return False;
	else :
		return True;
		
root = Tk();

w = Canvas(root,width=600,height=600);
w.pack();
print "intializing..."
print "processing..."

for x in range(0,600) :
	real = xa + (xb - xa) * x / 600;
	for y in  range(0,600):
		img = ya + (yb - ya) * y / 600;
		c = complex(real,img);
		if(check(c)):
			w.create_line(x,600-y,x+1,601-y,fill="black");
			w.pack();
			
print "completed!!!";
root.mainloop();
