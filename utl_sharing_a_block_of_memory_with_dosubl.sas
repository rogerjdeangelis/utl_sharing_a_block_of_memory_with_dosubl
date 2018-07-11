Using a DOSUBL subroutine to replace numbers with their squares

github
https://tinyurl.com/y9dzonq2
https://github.com/rogerjdeangelis/utl_sharing_a_block_of_memory_with_dosubl

This is a proof of concept. Shared common block on memory with DOSUBL.


INPUT
=====

 WORK.HAVE total obs=5

  Obs    NUMBERS

   1         0
   2         4
   3         8
   4        12
   5        16


EXAMPLE OUTPUT  (Squares of Numbers)
------------------------------------

 WORK.WANT total obs=5  |  RULES
                        |
  Obs    NUMBERS        |  The DOSUBL subroutine uses the adresses of the the
                        |  'NUMBERS' and loads those addresses with the
   1         0          |  squares of NUMBERS.
   2        16          |
   3        64          |  The block of memory containing 'NUMBERS' is
   4       144          |  shared with DOSUBL.
   5       256          |


PROCESS
=======

  data want;

      %commonn(numbers,action=INIT);

      set have;

      rc=dosubl('
        data _null_;

           %commonn(numbers,action=GET);
           squares=numbers*numbers;
           %commonn(squares,action=PUT);

        run;quit;
      ');

      drop rc;

  run;quit;


OUTPUT
======

data have;
  do numbers=0 to 16 by 4;
     output;
  end;
run;quit;


*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%macro commonn(var,action=init);
   %if %upcase(&action) = INIT %then %do;
      retain &var 0;
      call symputx("varadr",put(addrlong(&var.),hex16.),"G");
   %end;
   %else %if "%upcase(&action)" = "PUT" %then %do;
      call pokelong(&var,"&varadr."x);
   %end;
   %else %if "%upcase(&action)" = "GET" %then %do;
      &var = input(peekclong("&varadr."x,8),rb8.);
   %end;
%mend commonn;



