use strict;
use warnings;

my $dprfn = 'TestCase.pas';

my $ArgType = 'Integer';
my $TargetClassName = 'TTestTarget';
my $HookClassName = 'TTestHook';

my $TargetObjName = 'ObjTestTarget';
my $HookObjName = 'ObjTestHook';

my @ParamRange = ( 0 .. 19 );
my @ExtraParamRange = ( 0 .. 9 );
my @CallingConvention = ( '', ' stdcall', ' cdecl' );
my @CallingConventionValue = ( 'HCC_REGISTER', 'HCC_STDCALL', 'HCC_CDECL' );
my $NewLine = "\n      ";

my @PreParamValues;

my @lines;
my %Tags = (
);

@CallingConvention = ( '' );
@CallingConventionValue = ( 'HCC_REGISTER' );

&GenTagValues(\%Tags);
open FH, $dprfn or die "Can't open $dprfn to read.\n";
@lines = <FH>;
close FH;

#$Tags{$_} = '' foreach(keys %Tags);

my $curtag = '';
my $linenum = 0;
open FH, '>' . $dprfn or die "Can't open $dprfn to write.\n";
foreach(@lines) {
	my $ln = $_;
	$linenum++;
	
	if($ln =~ /^\s*\{\#\@(\w+)/) {
		print FH $ln;

		my $t = $1;
		
		die "Can't find tag $t at line $linenum.\n" unless(exists($Tags{$t}));
		if($curtag eq '') {
			$curtag = $t;
			print FH $Tags{$t};
		}
		else {
			die "Mis-close tag $t at line $linenum.\n" unless($t eq $curtag);
			$curtag = '';
		}
	}
	else {
		print FH $ln if($curtag eq '');
	}
}
close FH;


sub GenTagValues
{
	my $tags = shift;
	my $functions = '';
	my $type = '';
	my @target = ();
	my @hook = ();
	
	srand;
	foreach(@CallingConvention) {
		my $cc = $_;
		
		foreach(@ParamRange) {
			my $paramcount = $_;
			push @target, &GenTarget($cc, $paramcount, 1);
		}
		
		foreach(@ExtraParamRange) {
			my $paramcount = $_;
			push @hook, &GenHook($cc, $paramcount, 1);
		}
	}
	
	$type .= '  ' . $TargetClassName . " = class\n";
	
	foreach(@target) {
		my $t = $_;
		$type .= '    ' . $t->{Prototype} . "\n";
	}
	$type .= "  end;\n\n";
	
	$type .= '  ' . $HookClassName . " = class\n";
	
	foreach(@hook) {
		my $t = $_;
		$type .= '    ' . $t->{Prototype} . "\n";
	}
	$type .= "  end;\n\n";
	
	foreach(@CallingConvention) {
		my $cc = $_;
		
		foreach(@ParamRange) {
			my $paramcount = $_;
			push @target, &GenTarget($cc, $paramcount, 0);
		}
		
		foreach(@ExtraParamRange) {
			my $paramcount = $_;
			push @hook, &GenHook($cc, $paramcount, 0);
		}
	}
	foreach(@target) {
		my $t = $_;
		$type .= $t->{Prototype} . "\n" unless($t->{IsObj});
	}
	foreach(@hook) {
		my $t = $_;
		$type .= $t->{Prototype} . "\n" unless($t->{IsObj});
	}
	
	foreach(@target) {
		my $t = $_;
		$functions .= $t->{PrototypeImpl} . "\n" . $t->{Body} . "\n\n";
	}
	
	foreach(@hook) {
		my $t = $_;
		$functions .= $t->{PrototypeImpl} . "\n" . $t->{Body} . "\n\n";
	}
	
	$functions .= "procedure TestCaseExecute;\nbegin\n";
	foreach(@target) {
		my $t = $_;
		$functions .= '  ' . $t->{Run} . "\n";
	}
	$functions .= "end;\n";

	$functions .= "procedure TestCaseTargetHook(AHookObj: Pointer; AHook: Pointer; ACC: Integer; AExtraParams: PCardinal; AExtraParamCount: Integer);\nbegin\n";
	foreach(@target) {
		my $t = $_;
		$functions .= $t->{Hook} . "\n\n";
	}
	$functions .= "end;\n";

	$functions .= "procedure TestCaseTargetUnhook;\nbegin\n";
	foreach(@target) {
		my $t = $_;
		$functions .= $t->{Unhook} . "\n";
	}
	$functions .= "end;\n";

	$functions .= "procedure TestCaseRun;\nbegin\n";
	foreach(@hook) {
		my $t = $_;
		$functions .= $t->{Hook} . "\n";
		$functions .= "  TestCaseExecute;\n";
		$functions .= $t->{Unhook} . "\n";
	}
	$functions .= "end;\n";

	$tags->{Functions} = $functions;
	$tags->{Type} = $type;
}

sub GetFuncName
{
	my ($funcname, $paramcount, $istarget, $isobj) = @_;
	my $prefix = 'TestHook_';
	$prefix = 'TestTarget_' if($istarget);
	if($isobj) {
		$prefix = 'Obj' . $prefix;
	}
	else {
		$prefix = 'G' . $prefix;
	}
	$funcname =~ s/\s+//;
	$funcname = 'reg' if($funcname eq '');
	$funcname = lcfirst $funcname;
	$funcname = $prefix . $funcname . $paramcount;
	
	return $funcname;
}

sub GenNoise
{
	my $i = shift;
	
	return '*' . ($i + 1);
}

sub GenParamValues
{
	my ($params, $count) = @_;
	my $i = 30;

	return unless($count);
	
	$i = $count if($count > $i);

	while($#PreParamValues < $i - 1) {
		push @PreParamValues, ($#PreParamValues + 2);
	}
	
	foreach(1..$i) {
		my $index1 = int(rand($count));
		my $index2 = int(rand($count));

		if($index1 == $index2) {
			$index1 = ($index1 + 1) % $count;
		}
		($PreParamValues[$index1], $PreParamValues[$index2])
			= ($PreParamValues[$index2], $PreParamValues[$index1]);
	}
	
	for($i = 0; $i < $count; $i++) {
		$params->[$i] = 1; #$PreParamValues[$i];
	}
}

sub DoBreakLine
{
	my ($code, $delimiter, $del) = @_;
	my $maxlen = 900;
	
	$del = $delimiter unless(defined $del);

	if(length($code) > $maxlen) {
		my @lines = split($delimiter, $code);
		my $s = '';
		my $t = '';
		$code = '';
		
		while($#lines >= 0) {
			$t = shift @lines;
			if(length($s . $del . $t) > $maxlen) {
				$code .= $del . "\n      " if($code ne '');
				$code .= $s;
				$s = $t;
			}
			else {
				$s .= $del unless($s eq '');
				$s .= $t;
			}

			if($#lines < 0) {
				$code .= $del unless($code eq '');
				$code .= "\n      " . $s;
			}
		}
	}
	
	return $code;
}

sub BreakLine
{
	my ($code) = @_;
	
	$code = &DoBreakLine($code, ', ');
	$code = &DoBreakLine($code, '; ');
	$code = &DoBreakLine($code, qr(\+\s), '+ ');
	
	return $code;
}

sub BreakCode
{
	my $code = shift;
	my @lines = split("\n", $code);
	
	foreach(@lines) {
		$_ = &BreakLine($_);
	}
	$code = join("\n", @lines);
	
	return $code;
}

sub BreakFunc
{
	my $f = shift;

	$f->{Prototype} = &BreakCode($f->{Prototype});
	$f->{PrototypeImpl} = &BreakCode($f->{PrototypeImpl});
	$f->{Body} = &BreakCode($f->{Body});
	$f->{Run} = &BreakCode($f->{Run});
	$f->{Hook} = &BreakCode($f->{Hook});
	$f->{Unhook} = &BreakCode($f->{Unhook});
}

sub AddpenStr
{
	my ($s, $append) = @_;
	
	if(length($s) > 900) {
		$s .= "\n      ";
	}

	return $s . $append;
}

sub GenTarget
{
	my ($cc, $paramcount, $isobj) = @_;
	my %result = (
		FuncName => '',
		FuncNameImpl => '',
		Prototype => '',
		PrototypeImpl => '',
		Body => '',
		IsObj => $isobj,
		Run => '',
		Hook => '',
		Unhook => '',
		ParamValues => [],
	);
	my $r = \%result;
	my ($i, $value, $passvalue) = (0, '', '');
	my @paramvalues = ();
	my $self = '';
	my $checkself = '';
	
	if($isobj) {
		$self = $TargetObjName . '.';
		$checkself = '  CheckAssert(Self = ' . $TargetObjName . ");\n";
	}
	
	$r->{FuncName} = &GetFuncName($cc, $paramcount, 1, $isobj);
	$r->{FuncNameImpl} = $r->{FuncName};
	$r->{FuncNameImpl} = $TargetClassName . '.' . $r->{FuncNameImpl} if($isobj);
	
	for($i = 0; $i <= $#CallingConvention; $i++) {
		if($cc eq $CallingConvention[$i]) {
			$r->{CCValue} = $CallingConventionValue[$i];
		}
	}

	&GenParamValues(\@paramvalues, $paramcount);
	$r->{ParamValues} = \@paramvalues;

	for($i = 0; $i < $paramcount; $i++) {
		$r->{Prototype} .= '; ' if($i > 0);
		$r->{PrototypeImpl} .= '; ' if($i > 0);
		$r->{Body} .= ' + ' if($i > 0);
		
		$value .= ' + ' if($i > 0);
		$passvalue .= ', ' if($i > 0);

		$r->{Prototype} .= 'Arg' . $i . ': ' . $ArgType;
		$r->{PrototypeImpl} .= 'Arg' . $i . ': ' . $ArgType;
		$r->{Body} .= 'Arg' . $i . &GenNoise($i);
		
		$value .= $paramvalues[$i] . &GenNoise($i);
		$passvalue .= $paramvalues[$i];
		
		if($i > 0 && $i % 50 == 0) {
			$r->{Prototype} .= $NewLine;
			$r->{PrototypeImpl} .= $NewLine;
			$r->{Body} .= $NewLine;
			$value .= $NewLine;
			$passvalue .= $NewLine;
		}
	}
	if($paramcount > 0) {
		$r->{Prototype} = '(' . $r->{Prototype} . ')';
		$r->{PrototypeImpl} = '(' . $r->{PrototypeImpl} . ')';
		$passvalue = '(' . $passvalue . ')';
	}
	else {
		$r->{Body} = '0';
		$value = $r->{Body};
	}

	$r->{Run} = 'CheckValue(' . $value . ', ' . $self . $r->{FuncName} . $passvalue . ");";
	$cc .= ';' if($cc ne '');	
	$r->{Prototype} = 'function ' . $r->{FuncName} . $r->{Prototype} . ': ' . $ArgType . ';' . $cc;
	$r->{PrototypeImpl} = 'function ' . $r->{FuncNameImpl} . $r->{PrototypeImpl} . ': ' . $ArgType .';' . $cc;
	$r->{Body} = '  Result := ' . $r->{Body} . ';';
	$r->{Body} = "begin\n" . $checkself . $r->{Body} . "\nend;";
	
	$self = 'nil' if($self eq '');
	$r->{Hook} .= "  GCodeHookHelper.SetCallingConvention(" . $r->{CCValue} . ", ACC);\n";
	$r->{Hook} .= "  if AHookObj <> nil then GCodeHookHelper.HookWithObjectMethodExtra(" . ($isobj ? $TargetObjName : 'nil')
		. ", AHookObj, \@" . $r->{FuncNameImpl} . ", AHook, " . $paramcount . ", AExtraParams, AExtraParamCount, 0)\n";
	$r->{Hook} .= "  else ";
	$r->{Hook} .= "GCodeHookHelper.HookWithGlobalMethodExtra(" . ($isobj ? $TargetObjName : 'nil')
		. ", \@" . $r->{FuncNameImpl} . ", AHook, " . $paramcount . ", AExtraParams, AExtraParamCount, 0);";
		
	$r->{Unhook} .= '  GCodeHookHelper.UnhookTarget(@' . $r->{FuncNameImpl} . ');';
	
#	&BreakFunc($r);
	
	return $r;
}

sub GenHook
{
	my ($cc, $paramcount, $isobj) = @_;
	my %result = (
		FuncName => '',
		FuncNameImpl => '',
		Prototype => '',
		PrototypeImpl => '',
		Body => '',
		IsObj => $isobj,
		Run => '',
		Hook => '',
		Unhook => '',
	);
	my $r = \%result;
	my ($i, $value, $passvalue) = (0, '', '');
	my @paramvalues = ();
	my $self = '';
	my $bodyline = '';
	my $checkself = '';
	
	if($isobj) {
		$self = $HookObjName . '.';
		$checkself = '  CheckAssert(Self = ' . $HookObjName . ");\n";
	}
	
	$r->{FuncName} = &GetFuncName($cc, $paramcount, 0, $isobj);
	$r->{FuncNameImpl} = $r->{FuncName};
	$r->{FuncNameImpl} = $HookClassName . '.' . $r->{FuncNameImpl} if($isobj);
	
	for($i = 0; $i <= $#CallingConvention; $i++) {
		if($cc eq $CallingConvention[$i]) {
			$r->{CCValue} = $CallingConventionValue[$i];
		}
	}

	&GenParamValues(\@paramvalues, $paramcount);

	for($i = 0; $i < $paramcount; $i++) {
		$r->{Prototype} .= '; ' if($i > 0);
		$r->{PrototypeImpl} .= '; ' if($i > 0);
		$r->{Body} .= ' + ' if($i > 0);
		
		$value .= ' + ' if($i > 0);
		$passvalue .= ', ' if($i > 0);

		$r->{Prototype} .= 'Arg' . $i . ': ' . $ArgType;
		$r->{PrototypeImpl} .= 'Arg' . $i . ': ' . $ArgType;
		$r->{Body} .= 'Arg' . $i;
		
		$value .= $paramvalues[$i];
		$passvalue .= $paramvalues[$i];
		
		if($i > 0 && $i % 50 == 0) {
			$r->{Prototype} .= $NewLine;
			$r->{PrototypeImpl} .= $NewLine;
			$r->{Body} .= $NewLine;
			$value .= $NewLine;
			$passvalue .= $NewLine;
		}
	}
	$r->{Prototype} .= '; ' if($paramcount > 0);
	$r->{Prototype} .= 'AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor';
	$r->{PrototypeImpl} .= '; ' if($paramcount > 0);
	$r->{PrototypeImpl} .= 'AHandle: TCodeHookHandle; AParams: PCodeHookParamAccessor';
	
	$r->{Prototype} = '(' . $r->{Prototype} . ')';
	$r->{PrototypeImpl} = '(' . $r->{PrototypeImpl} . ')';
	$passvalue = '(' . $passvalue . ')';
	$r->{Body} = '0';
	$value = $r->{Body};

	$r->{Run} = 'CheckValue(' . $value . ', ' . $self . $r->{FuncName} . $passvalue . ");";
	$cc .= ';' if($cc ne '');	
	$r->{Prototype} = 'function ' . $r->{FuncName} . $r->{Prototype} . ': Cardinal;' . $cc;
	$r->{PrototypeImpl} = 'function ' . $r->{FuncNameImpl} . $r->{PrototypeImpl} . ': Cardinal;' . $cc;
	
	if($paramcount > 0) {
		for($i = 0; $i < $paramcount; $i++) {
			$bodyline .= "  CheckValue(ExtraParams[$i], Arg$i);\n";
		}
	}
	$r->{Body} = <<EOM;
var
  I: Integer;
  V: Integer;
  lInfo: TCodeHookInfo;

begin
$checkself
$bodyline
  GCodeHook.GetHookInfo(AHandle, \@lInfo);
  V := 0;
  for I := 0 to lInfo.ParamCount - 1 do
    V := V + Integer(AParams[I]) * (I + 1);

  Result := GCodeHook.CallPreviousMethod(AHandle, AParams);

  CheckValue(V, Result);
end;
EOM

	$r->{Hook} .= '  TestCaseTargetHook(' . ($isobj ? $HookObjName : 'nil')
		. ', @' . $r->{FuncNameImpl} . ', ' . $r->{CCValue} . ', ' . '@ExtraParams[0]' . ', ' . $paramcount . ');';
	$r->{Unhook} .= '  TestCaseTargetUnhook;';
	
#	&BreakFunc($r);

	return $r;
}
