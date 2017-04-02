function retval = datestr(date, f = [], p = [])
% [Obtained from http://hg.savannah.gnu.org/hgweb/octave/file/68dbde0e670a/scripts/time/datestr.m following bug report https://savannah.gnu.org/bugs/index.php?50673

  persistent dateform names_mmmm names_m names_d;

  if (isempty (dateform))
    dateform = cell (32, 1);
    dateform{1}  = "dd-mmm-yyyy HH:MM:SS";
    dateform{2}  = "dd-mmm-yyyy";
    dateform{3}  = "mm/dd/yy";
    dateform{4}  = "mmm";
    dateform{5}  = "m";
    dateform{6}  = "mm";
    dateform{7}  = "mm/dd";
    dateform{8}  = "dd";
    dateform{9}  = "ddd";
    dateform{10} = "d";
    dateform{11} = "yyyy";
    dateform{12} = "yy";
    dateform{13} = "mmmyy";
    dateform{14} = "HH:MM:SS";
    dateform{15} = "HH:MM:SS PM";
    dateform{16} = "HH:MM";
    dateform{17} = "HH:MM PM";
    dateform{18} = "QQ-YY";
    dateform{19} = "QQ";
    dateform{20} = "dd/mm";
    dateform{21} = "dd/mm/yy";
    dateform{22} = "mmm.dd,yyyy HH:MM:SS";
    dateform{23} = "mmm.dd,yyyy";
    dateform{24} = "mm/dd/yyyy";
    dateform{25} = "dd/mm/yyyy";
    dateform{26} = "yy/mm/dd";
    dateform{27} = "yyyy/mm/dd";
    dateform{28} = "QQ-YYYY";
    dateform{29} = "mmmyyyy";
    dateform{30} = "yyyy-mm-dd";
    dateform{31} = "yyyymmddTHHMMSS";
    dateform{32} = "yyyy-mm-dd HH:MM:SS";

    names_m = {"J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"};
    names_d = {"S", "M", "T", "W", "T", "F", "S"};
  endif

  if (nargin < 1 || nargin > 3)
    print_usage ();
  endif

  ## Guess input type.  We might be wrong.
  if (ischar (date) || iscellstr (date) || columns (date) != 6)
    v = datevec (date, p);
  else
    v = [];
    if (columns (date) == 6)
      ## Make sure that the input really is a datevec.
      maxdatevec = [Inf, 12, 31, 23, 59, 60];
      if (any (max (date, 1) > maxdatevec)
          || any (date(:,1:5) != floor (date(:,1:5))))
        v = datevec (date, p);
      endif
    endif
    if (isempty (v))
      v = date;
    endif
  endif

  ## Round fractional seconds >= 0.9995 s to next full second.
  idx = v(:,6) - fix (v(:,6)) >= 0.9995;
  if (any (idx))
    v(idx,6) = fix (v(idx,6)) + 1;
    v(idx,:) = datevec (datenum (v(idx,:)));
  endif

  ## Automatic format selection
  if (isempty (f))
    if (v(:,4:6) == 0)
      f = 1;
    elseif (v(:,1:3) == [-1, 12, 31])
      f = 16;
    else
      f = 0;
    endif
  endif

  retval = "";
  for i = 1 : rows (v)

    if (isnumeric (f))
      df = dateform{f + 1};
    else
      df = f;
    endif

    df_orig = df;
    df = strrep (df, "AM", "%p");
    df = strrep (df, "PM", "%p");
    if (strcmp (df, df_orig))
      ## PM not set.
      df = strrep (df, "HH", "%H");
    else
      hr = mod (v(i,4), 12);
      if (hr == 0)
        hr = 12;
      endif
      df = strrep (df, "HH", sprintf ("%2d", hr));
    endif

    df = regexprep (df, "[Yy][Yy][Yy][Yy]", "%Y");

    df = regexprep (df, "[Yy][Yy]", "%y");

    df = regexprep (df, "[Dd][Dd][Dd][Dd]", "%A");

    df = regexprep (df, "[Dd][Dd][Dd]", "%a");

    df = regexprep (df, "[Dd][Dd]", "%d");

    wday = weekday (datenum (v(i,1), v(i,2), v(i,3)));
    tmp = names_d{wday};
    df = regexprep (df, "([^%])[Dd]", sprintf ("$1%s", tmp));
    df = regexprep (df, "^[Dd]", sprintf ("%s", tmp));

    df = strrep (df, "mmmm", "%B");

    df = strrep (df, "mmm", "%b");

    df = strrep (df, "mm", "%m");

    tmp = names_m{v(i,2)};
    pos = regexp (df, "[^%]m") + 1;
    df(pos) = tmp;
    df = regexprep (df, "^m", tmp);

    df = strrep (df, "MM", "%M");

    df = regexprep (df, "[Ss][Ss]", "%S");

    df = strrep (df, "FFF", sprintf ("%03d",
                                     round (1000 * (v(i,6) - fix (v(i,6))))));

    df = strrep (df, "QQ", sprintf ("Q%d", fix ((v(i,2) + 2) / 3)));

    vi = v(i,:);
    tm.year = vi(1) - 1900;
    tm.mon = vi(2) - 1;
    tm.mday = vi(3);
    tm.hour = vi(4);
    tm.min = vi(5);
    sec = vi(6);
    tm.sec = fix (sec);
    tm.usec = fix ((sec - tm.sec) * 1e6);
    tm.wday = wday - 1;
    ## FIXME: Do we need YDAY and DST?  How should they be computed?
    ## We don't want to use "localtime (mktime (tm))" because that
    ## doesn't correctly handle dates before 1970-01-01 on some systems.
    ## tm.yday = ?;
    ## tm.isdst = ?;

    str = strftime (df, tm);

    retval = [retval; str];

  endfor

endfunction
