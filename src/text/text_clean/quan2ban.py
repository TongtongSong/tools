# -*- coding: utf-8 -*-
import sys

def strQ2B(inputFilePath,outputFilePath):
    outputFile = open(outputFilePath,'w')
    with open(inputFilePath) as inputFile:
        lines = inputFile.readlines()
        for line in lines:
            ustring = line.decode('utf-8')

            rstring = ""  
            for uchar in ustring:  
                inside_code=ord(uchar)  
                if inside_code == 12288:                              #全角空格直接转换              
                    inside_code = 32   
                elif (inside_code >= 65281 and inside_code <= 65374): #全角字符（除空格）根据关系转化  
                    inside_code -= 65248   
                rstring += unichr(inside_code)
            outputFile.write(rstring.encode('utf-8'))
    outputFile.close()
        
if __name__ == "__main__":
    inputFilePath = sys.argv[1]     
    outputFilePath = sys.argv[2]
    strQ2B(inputFilePath,outputFilePath)                             
 

