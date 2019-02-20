# Blitzy

**Description**
 This is a distributed load tester, it will require you to run three separate elixir shells named bravo, charlie and delta. Each of these will turn into supervised elixir processes that can spawn workers that will issue a request to the specified url. 
 
 NOTE: Use at your own risk.

## Usage

Make sure to cd into the root directory of the project first, then open three terminal tabs and in each one start a new named interactive elixir shell:

TAB 1:
iex --name bravo@127.0.0.1 -S mix
TAB 2:
iex --name charlie@127.0.0.1 -S mix
TAB 3:
iex --name delta@127.0.0.1 -S mix


In another tab, compile the script using the command:
mix escript.build

Once this is done you should have a file called blitzy in the same directory.
Make sure that bravo, charlie and delta are up and running, then type:
./blitzy -n <number_of_requests> <any_url_goes_here>

Example: ./blitzy -n 10000 http://www.google.com

The program will divide the number of requests by the number of available machines we've set up (including the one where you execute the actual command from, so in this case four) and issue each request to spawn a new worker for each request under a supervision tree on each machine. 

If everything is working you should be able to see the requests running in each window that is running the program.

Once everything is done, the process in which you executed the script from will display some statistics on all requests issued by (itself) and the other machines that helped out.