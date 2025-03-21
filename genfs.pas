program genfs;

uses genfsbase,fsbase,sysutils,classes, unit1;

{$mode ObjFPC}

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
 if(UpperCase(Copy(size,len-2,3))='MIB') then
  begin
   Result:=StrToInt(Copy(size,1,len-3));
  end
 else if(UpperCase(Copy(size,len-2,3))='GIB') then
  begin
   Result:=StrToInt(Copy(size,1,len-3)) shl 10;
  end
 else if(UpperCase(Copy(size,len-2,3))='TIB') then
  begin
   Result:=StrToInt(Copy(size,1,len-3)) shl 20;
  end
 else if(UpperCase(Copy(size,len-1,2))='MB') then
  begin
   Result:=StrToInt(Copy(size,1,len-2));
  end
 else if(UpperCase(Copy(size,len-1,2))='GB') then
  begin
   Result:=StrToInt(Copy(size,1,len-2)) shl 10;
  end
 else if(UpperCase(Copy(size,len-1,2))='TB') then
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
procedure genfs_run_command(param:array of Unicodestring);
var i:SizeUint;
    fs:genfs_filesystem;
    tempnum:SizeUint;
begin
 if(FileExists(param[1])=false) and (Lowercase(param[0])<>'create') then
  begin
   writeln('ERROR:image file does not exist.');
   readln;
   abort;
  end;
 if(LowerCase(param[0])='create') then
  begin
   if(length(param)<4) then
    begin
     writeln('ERROR:Too Few Arguments for create command.');
     readln;
     abort;
    end;
   tempnum:=genfs_size_to_number(param[3]);
   if(LowerCase(param[2])='fat32') or (tempnum>2048) then
   fs:=genfs_filesystem_create(param[1],filesystem_fat32,tempnum,
   [Word(512),Byte(1),Word(8),Dword(tempnum shl 4),Word(6),Word(1),Word(2)])
   else if(LowerCase(param[2])='fat16') or (tempnum>60) then
   fs:=genfs_filesystem_create(param[1],filesystem_fat16,tempnum,
   [Word(512),Byte(1),Word(8),Word(tempnum shl 4)])
   else if(LowerCase(param[2])='fat12') then
   fs:=genfs_filesystem_create(param[1],filesystem_fat12,tempnum,
   [Word(512),Byte(1),Word(8),Word(tempnum shl 4)]);
   genfs_filesystem_free(fs);
  end
 else if(LowerCase(param[0])='add') then
  begin
   if(length(param)<4) then
    begin
     writeln('ERROR:Too Few Arguments for add command.');
     readln;
     abort;
    end;
   fs:=genfs_filesystem_read(param[1]);
   genfs_filesystem_add_file(fs,param[2],param[3]);
   genfs_filesystem_free(fs);
  end
 else if(LowerCase(param[0])='copy') then
  begin
   if(length(param)<4) then
    begin
     writeln('ERROR:Too Few Arguments for copy command.');
     readln;
     abort;
    end;
   fs:=genfs_filesystem_read(param[1]);
   genfs_filesystem_copy_file(fs,param[2],param[3]);
   genfs_filesystem_free(fs);
  end
 else if(LowerCase(param[0])='move') then
  begin
   writeln('Move command is not supported yet,waiting for next version.');
   readln;
   abort;
  end
 else if(LowerCase(param[0])='delete') then
  begin
   if(length(param)<3) then
    begin
     writeln('ERROR:Too Few Arguments for delete command.');
     readln;
     abort;
    end;
   fs:=genfs_filesystem_read(param[1]);
   genfs_filesystem_delete_file(fs,param[2]);
   genfs_filesystem_free(fs);
  end
 else if(LowerCase(param[0])='erase') then
  begin
   if(length(param)<3) then
    begin
     writeln('ERROR:Too Few Arguments for erase command.');
     readln;
     abort;
    end;
   fs:=genfs_filesystem_read(param[1]);
   genfs_filesystem_delete_file(fs,param[2]);
   genfs_filesystem_free(fs);
  end
 else if(LowerCase(param[0])='replace') then
  begin
   writeln('Replace command is not supported yet,waiting for next version.');
   readln;
   abort;
  end
 else if(LowerCase(param[0])='extract') then
  begin
   if(length(param)<4) then
    begin
     writeln('ERROR:Too Few Arguments for delete command.');
     readln;
     abort;
    end;
   fs:=genfs_filesystem_read(param[1]);
   genfs_filesystem_extract_file(fs,param[2],param[3]);
   genfs_filesystem_free(fs);
  end;
end;
var myparam:array of Unicodestring;
    i:SizeUint;
begin
 if(ParamCount<3) then
  begin
   writeln('genfs:Too few parameter,Show the help:');
   writeln('Template:genfs [commands] [parameters]');
   writeln('Vaild Commands:create/add/copy/move/delete/erase/replace/extract');
   writeln('               create [imagename] [filesystemtype] [Size in MiB]');
   writeln('               Vaild File System Type:fat12/fat16/fat32');
   writeln('               add [imagename] [Source File] [Destination File]');
   writeln('               copy [imagename] [Source File In Image] [Destination File In Image]');
   writeln('               move is not supported yet,it will appear in next version.');
   writeln('               delete [imagename] [Delete File In Image]');
   writeln('               erase [imagename] [Thoroughly delete File In Image]');
   writeln('               replace is not supported yet,it will appear in next version');
   writeln('               extract [imagename] [Source File In Image] [Destination File Outside the Image]');
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

