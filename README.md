# ring.vim

Quickly jump to related files in your Rails project.

`:Ring <tab>` on file `app/models/thing.rb` will autocomplete:

```
spec/models/thing_spec.rb
app/controllers/things_controller.rb
app/views/things/index.html.erb
```

Press enter to `:edit` the file.

Hit `]r` and `[r` to jump to the next and previous related files respectively.
