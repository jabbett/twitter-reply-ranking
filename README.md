# twitter-reply-ranking

Fetch Tweet data from a cohort of screen names to rank based on number of replies. This is the code I used for publishing rankings of Massachusetts mayors, state representatives, state senators, statewide offices, and congressional delgation on [abbett.org](http://abbett.org)

* [Twitter Rankings: Massachusetts State Representatives](http://abbett.org/2018/11/twitter-rankings-massachusetts-state-representatives/index.html)
* [Twitter Rankings: Massachusetts State Senators](http://abbett.org/2018/11/twitter-rankings-massachusetts-state-senators/index.html)
* [Twitter Rankings: Massachusetts Mayors](http://abbett.org/2018/11/twitter-rankings-massachusetts-mayors/index.html)
* [Twitter Rankings: Massachusetts Statewide & Congressional](http://abbett.org/2018/11/twitter-rankings-massachusetts-statewide-congress/index.html)

## Set up

1. Apply for a [Twitter developer account](https://developer.twitter.com/en/apply/user)
2. Once approved, [create an app](https://developer.twitter.com/en/apps/create) to generate a set of Twitter API keys and access tokens.
3. Clone the `twitter-reply-ranking` repository to your computer.
4. Copy `credentials.orig.json` to `credentials.json` and fill in the fields with your new keys & tokens.
5. Install Ruby (if you don't have it already).

## Usage

```
cd twitter-reply-ranking
gem install twitter
ruby twitter-reply-ranking.rb cohorts/ma_mayors.json templates/stats_mayors.html.erb
```

Replace the `cohort` path with the cohort of your choice. Replace the `templates` path with the output template of your choice.

## Cohort files

...are each simply an array of JSON objects stored as `.json` files in the `cohorts` subdirectory. The only fields you absolutely need in each object are `first`, `last`, and `screen_name`, though each output template makes its own demands for fields - you might see rendering errors if there's a mismatch. (There's definitely work to be done to make this more flexible/generic.)

## Output templates

...are each ERB files stored in the `templates` subdirectory. They're currently a mix of Markdown and HTML, since that's what my Jekyll-driven website likes. Make them anything you like!

## Cohort/template combinations that work out of the box

```
ruby twitter-reply-ranking.rb cohorts/ma_mayors.json templates/stats_mayors.html.erb
```

```
ruby twitter-reply-ranking.rb cohorts/ma_state_reps.json templates/stats.html.erb
ruby twitter-reply-ranking.rb cohorts/ma_state_senators.json templates/stats.html.erb
```

```
ruby twitter-reply-ranking.rb cohorts/ma_statewide.json templates/stats_statewide.html.erb
```

## Questions? Need help?

Post an issue in this repository, or message me on Twitter: [@jonabbett](https://twitter.com/jonabbett)

If you want to make new & interesting cohorts, post it in a pull request and I can include it.