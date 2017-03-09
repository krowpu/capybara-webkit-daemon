Capybara::Webkit::Daemon
========================

Long-living Capybara Webkit server process which does not leak memory
when used in Sidekiq workers. The daemon is listening on a specific TCP
port, runs `webkit_server` process for each connection and kills it when
connection is closed or aborted. Can be used for web scraping when
Capybara Webkit causes `Errno::EMFILE: Too many open files` error.
You ever can run it on machine different from where your worker is running.
However in this case some features may not work (screenshots, for example).
