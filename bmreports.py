import httplib
import urllib
#httplib.HTTPConnection.debuglevel = 1


data = urllib.urlopen("http://www.bmreports.com/bsp/additional/soapfunctions.php?element=systemprices&submit=Invoke").read()
print data
