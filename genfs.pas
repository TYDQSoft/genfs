program genfs;

uses genfsbase,fsbase,sysutils,classes;

function StrToInt(str:UnicodeString):SizeInt;
var i,len:SizeUint;
begin
 Result:=0; len:=length(str);
 if(length(str)=0) then exit(Result)
 else
  begin
   if(str[1]='-') then
    begin
     i:=2;
     while(i<=len)do
      begin
       Result:=Result*10+Word(str[i])-Word('0');
       inc(i);
      end;
     Result:=-Result;
    end
   else
    begin
     i:=1;
     while(i<=len)do
      begin
       Result:=Result*10+Word(str[i])-Word('0');
       inc(i);
      end;
    end;
  end;
end;
function genfs_size_to_number(inputsize:UnicodeString):SizeUint;
var i,len:SizeUint;
    size:UnicodeString;
begin
 size:=UpperCase(inputsize);
 len:=length(size);
 if(Copy(size,len-2,3)='MIB') then
  begin
   Result:=StrToInt(Copy(size,1,len-3));
  end
 else if(Copy(size,len-2,3)='GIB') then
  begin
   Result:=StrToInt(Copy(size,1,len-3)) shl 10;
  end
 else if(Copy(size,len-2,3)='TIB') then
  begin
   Result:=StrToInt(Copy(size,1,len-3)) shl 20;
  end
 else if(Copy(size,len-1,2)='MB') then
  begin
   Result:=StrToInt(Copy(size,1,len-2));
  end
 else if(Copy(size,len-1,2)='GB') then
  begin
   Result:=StrToInt(Copy(size,1,len-2)) shl 10;
  end
 else if(Copy(size,len-1,2)='TB') then
  begin
   Result:=StrToInt(Copy(size,1,len-2)) shl 20;
  end
 else
  begin
   writeln('ERROR:Unrecognized Size Number '+size+'.');
   readln;
   abort;
  end;
end;
function genfs_path_legal(str:UnicodeString):boolean;
var i:SizeUint;
begin
 i:=length(str);
 if(length(str)=0) then exit(false);
 while(i>0)do
  begin
   if(str[i]='*') or (str[i]='?') then exit(false);
   dec(i);
  end;
 genfs_path_legal:=true;
end;
procedure genfs_run_command(param:array of Unicodestring);
var i:SizeUint;
    fs:genfs_filesystem;
    tempnum1,tempnum2:SizeUint;
begin
 if(length(param)>=1) then
  begin
   if(LowerCase(param[0])='create') then
    begin
     if(length(param)<4) then
      begin
       writeln('ERROR:parameter too few.');
       readln;
       abort;
      end
     else if(length(param)>4) then
      begin
       writeln('ERROR:parameter too much.');
       readln;
       abort;
      end;
     tempnum1:=genfs_size_to_number(param[3]);
     tempnum2:=tempnum1 shl 20;
     if(LowerCase(param[2])='fat12') and (tempnum1<=20) then
     fs:=genfs_filesystem_create(param[1],filesystem_fat12,tempnum1,[512,1,Word(2),tempnum2 shr 16])
     else if(LowerCase(param[2])='fat16') and (tempnum1<=2048) then
     fs:=genfs_filesystem_create(param[1],filesystem_fat16,tempnum1,[512,1,Word(2),tempnum2 shr 16])
     else if(LowerCase(param[2])='fat32') then
     fs:=genfs_filesystem_create(param[1],filesystem_fat32,tempnum1,[512,1,Word(8),tempnum2 shr 16,
     Word(6),Word(1),Word(2)])
     else
      begin
       writeln('ERROR:File System not recognized.');
       readln;
       abort;
      end;
     genfs_filesystem_free(fs);
    end
   else if(LowerCase(param[0])='add') or (Lowercase(param[0])='copyin')
   or (LowerCase(param[0])='movein') then
    begin
     if(FileExists(param[1])) then
     fs:=genfs_filesystem_read(param[1])
     else
      begin
       writeln('ERROR:Image does not exist.');
       readln;
       abort;
      end;
     if(genfs_path_legal(param[3])=false) then
      begin
       writeln('ERROR:Destination Path is illegal.');
       readln;
       abort;
      end;
     genfs_filesystem_add(fs,param[2],param[3]);
     genfs_filesystem_free(fs);
    end
   else if(LowerCase(param[0])='delete') or (LowerCase(param[0])='erase') then
    begin
     if(FileExists(param[1])) then
     fs:=genfs_filesystem_read(param[1])
     else
      begin
       writeln('ERROR:Image does not exist.');
       readln;
       abort;
      end;
     genfs_filesystem_delete(fs,param[2]);
     genfs_filesystem_free(fs);
    end
   else if(LowerCase(param[0])='extract') or (LowerCase(param[0])='moveout')
   or (LowerCase(param[0])='copyout') then
    begin
     if(FileExists(param[1])) then
     fs:=genfs_filesystem_read(param[1])
     else
      begin
       writeln('ERROR:Image does not exist.');
       readln;
       abort;
      end;
     if(genfs_path_legal(param[3])=false) then
      begin
       writeln('ERROR:Destination File Path does not exist.');
       readln;
       abort;
      end;
     genfs_filesystem_extract(fs,param[2],param[3]);
     genfs_filesystem_free(fs);
    end
   else if(LowerCase(param[0])='copy') then
    begin
     if(FileExists(param[1])) then
     fs:=genfs_filesystem_read(param[1])
     else
      begin
       writeln('ERROR:Image does not exist.');
       readln;
       abort;
      end;
     if(genfs_path_legal(param[3])=false) then
      begin
       writeln('ERROR:Destination File Path does not exist.');
       readln;
       abort;
      end;
     genfs_filesystem_extract(fs,param[2],'Temp');
     genfs_filesystem_add(fs,'Temp',param[3]);
     RemoveDir('Temp');
     genfs_filesystem_free(fs);
    end
   else if(LowerCase(param[0])='move') then
    begin
     if(FileExists(param[1])) then
     fs:=genfs_filesystem_read(param[1])
     else
      begin
       writeln('ERROR:Image does not exist.');
       readln;
       abort;
      end;
     if(genfs_path_legal(param[3])=false) then
      begin
       writeln('ERROR:Destination File Path does not exist.');
       readln;
       abort;
      end;
     genfs_filesystem_extract(fs,param[2],'Temp');
     genfs_filesystem_add(fs,'Temp',param[3]);
     genfs_filesystem_delete(fs,param[2]);
     RemoveDir('Temp');
     genfs_filesystem_free(fs);
    end
   else if(LowerCase(param[0])='reset') then
    begin
     if(FileExists(param[1])) then DeleteFile(param[1])
     else
      begin
       writeln('ERROR:Reset File does not exist.');
       readln;
       abort;
      end;
     if(length(param)<4) then
      begin
       writeln('ERROR:parameter too few.');
       readln;
       abort;
      end
     else if(length(param)>4) then
      begin
       writeln('ERROR:parameter too much.');
       readln;
       abort;
      end;
     tempnum1:=genfs_size_to_number(param[3]);
     tempnum2:=tempnum1 shl 20;
     if(LowerCase(param[2])='fat12') and (tempnum1<=20) then
     fs:=genfs_filesystem_create(param[1],filesystem_fat12,tempnum1,[512,1,Word(2),tempnum2 shr 16])
     else if(LowerCase(param[2])='fat16') and (tempnum1<=2048) then
     fs:=genfs_filesystem_create(param[1],filesystem_fat16,tempnum1,[512,1,Word(2),tempnum2 shr 16])
     else if(LowerCase(param[2])='fat32') then
     fs:=genfs_filesystem_create(param[1],filesystem_fat32,tempnum1,[512,1,Word(8),tempnum2 shr 16,
     Word(6),Word(1),Word(2)])
     else
      begin
       writeln('ERROR:File System not specified.');
       readln;
       abort;
      end;
     genfs_filesystem_free(fs);
    end
   else if(LowerCase(param[0])='destroy') then
    begin
     if(FileExists(param[1])) then DeleteFile(param[1]);
    end;
  end
 else
  begin
   writeln('No parameters passed,program ended.');
   readln;
  end;
end;
var myparam:array of Unicodestring;
    i:SizeUint;
begin
 if(ParamCount<4) then
  begin
   writeln('genfs:Too few parameter,Show the help:');
   writeln('Template:genfs [commands] [parameters]');
   writeln('Vaild Commands:create/add/copyin/movein/delete/erase/move/copy/extract/copyout/moveout');
   writeln('               genfs create [imagepath] [File System Name] [size at least in MiBs]');
   writeln('               Create a virtual image file in your computer');
   writeln('               genfs add/copyin/movein [imagepath] [Source External Path] [Destination Inner Path]');
   writeln('               Add/Copy to/Move your file or directory to this virtual image file');
   writeln('               genfs delete/erase [imagepath] [Source Inner Path]');
   writeln('               Delete/Erase specified file in your image file.');
   writeln('               genfs move [imagepath] [Source Inner Path] [Destination Inner Path]');
   writeln('               Move your source path to your destination path(in your image).');
   writeln('               genfs copy [imagepath] [Source Inner Path] [Destination Inner Path]');
   writeln('               Copy your source path to your destination path(in your image).');
   writeln('               genfs reset [imagepath] [File System Name] [size at least in MiBs]');
   writeln('               Reset your virtual image file in your computer.');
   writeln('               genfs destroy [imagepath]');
   writeln('               Destroy your virtual image.');
   writeln('Example:genfs create fat.img fat32 64MB');
   readln;
   exit;
  end;
 SetLength(myparam,ParamCount);
 for i:=1 to ParamCount do
  begin
   myparam[i-1]:=StringToUnicodeString(ParamStr(i));
  end;
 genfs_run_command(myparam);
 writeln('Command Done!');
 readln;
end.

