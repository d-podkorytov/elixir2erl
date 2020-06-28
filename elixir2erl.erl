-module(elixir2erl).

-export([do_files/1, dir/1, dir_tree/1]).

-export([start/0,test/0,rb/2]).

-define(DIRS,["eex_lib",
"elixir_lib",
"ex_unit_lib",
"iex_lib",
"logger_lib",
"mix_lib"
]).

%%
%% API Functions
%%

start()-> dirs(), init:stop().
%dir_tree(".").

is_writable_dir({ok,{file_info,_,directory,read_write,
                         _, %{{2020,6,25},{5,13,11}},
                         _, %{{2020,6,25},{5,10,48}},
                         _, %{{2020,6,25},{5,10,48}},
                         _,_,_,_,_,_,_}}) -> true;

is_writable_dir(_)-> false.

dir_tree(Root)->
 {ok,L} = file:list_dir(Root),
 lists:map(fun(A)->
            try file:read_file_info(A) of
             R-> %logger:notice(#{item => A, stat => R}),
                 case is_writable_dir(R) of
                  true  -> io:format("=== Do dir ~p ===~n",[A]),
                           dir_tree(Root++"/"++A);
                  false -> try do_files([Root++"/"++A]) of R1->R1 catch Err1:Reason1:St1 -> {Err1,Reason1,St1,Root,A} end 
                   % needs checking if it *.beam file
                 end, 
                 R
            catch Err:Reason:St -> {Err,Reason,St,A}
            end 
           end, L).

dirs()-> lists:map(fun(A)-> dir(A) end ,?DIRS).

dir(Dir)->
 L=lext(Dir,".beam"),
 lists:map(fun(A)->try do_files([Dir++"/"++A]) of R->R 
                    catch Err:Reason:St -> {Err,Reason,St} 
                   end 
           end,
           L
          ).

test()->do_files(["beam/Elixir.IEx.History.beam"]). 

file(Beam = [H|_]) when is_integer(H) ->
    io:format(" ~p ",[Beam]),

    C=beam_lib:chunks(Beam ++ ".beam",[abstract_code]),
%    C=beam_lib:chunks(Beam ++ "",[abstract_code]),

    Cs=beam_lib:all_chunks(Beam ++ ".beam"),

    %logger:notice(#{c => C , chunks => Cs}),
    {ok,{_,[{abstract_code,{_Some,Abstract_Code}}]}} = C,

    %logger:notice(#{some => _Some , abstract_code => Abstract_Code}),

    {ok,File} = file:open(Beam ++ ".erld",[write]),

    io:fwrite(File,"%~s~n",["Processed by Elixir -> Erlang decompiler "++atom_to_list(?MODULE)]),
    io:fwrite(File,"%~s~n",["Decompiler elixir2erl made by Dmitrii Podkorytov "]),

    io:fwrite(File,"%~s~n",["URL http://github.com/d-podkorytov/elixir2erl"]),
    io:format(File,"%Decompilation date : ~p~n",[{date(),time()}]),
    
    io:fwrite(File,"~s~n", [erl_prettypr:format(erl_syntax:form_list(Abstract_Code))]),
    file:close(File).

do_files([H|T]) ->
%    %io:format(" ~p ",[[H|T]]),
    file(removebeam(H)),
%    try file(H) of R->R catch _:_ -> ok end,
    do_files(T);
%
do_files([]) ->  ok.

%do_files(Files) -> lists:map(fun(FN)-> file(FN) end, Files).
%%
%% Local Functions
%%

rb(Name,Ext)-> string:sub_string(Name,1,string:str(Name,Ext)-1).

removebeam(Name)-> rb(Name,".beam").

lext(Path,Ext)-> 
 lf(Path,fun(A,Acc)->
     case ends(A,Ext) of
      true -> [A|Acc];
      _    -> Acc
     end 
    end).

lf(Path,F2)->
 {ok,L} = file:list_dir(Path),
  lists:foldl(F2,[],L).

ends(Name,Ext)-> 
 string:str(Name,Ext) == (length(Name) - length(Ext) + 1).
