# example-godot-threaded-load-autoload-bug

A repository demonstrating an issue trying to background load a script which references an autoloaded scene.

## Issue description

Given an autoloaded scene (`AutoLoad`) and a script which references `Autoload` (`caller.gd`), attempting to background load a node which attaches `caller.gd` as a script _with `use_sub_threads` enabled_ will often produce an internal engine error:

```
E 0:00:08:0459   get_script: Caller thread can't call this function in this node (/root/Autoload). Use call_deferred() or call_thread_group() instead.
  <C++ Error>    Condition "!is_accessible_from_caller_thread()" is true. Returning: (Variant())
  <C++ Source>   scene/main/node.cpp:3864 @ get_script()
```

There are a few things to note:

- This error does not seem to prevent the loaded scene from running correctly.
- This error doesn't occur all of the time, so it's likely a race condition.
  - It occurs _nearly all of the time_ if the load request is invoked from a caller's `_ready` callback. Deferring the call to load the scene does _not_ fix the problem or decrease the rate of occurence under these circumstances.
  - It occurs _rarely_ if invoked as a result of a user input (e.g. a button press) _after_ the loader scene has been ready for a while.

### Workarounds

> NOTE: A workaround isn't required because there doesn't seem to be any negative consequences, but if the error is noisy, these are the options.

The following are workarounds:

- Don't background load resources using `use_sub_threads`.
- Don't directly reference an autoload within scripts. Instead, fetch the autoload: `get_node("/root/<auto-load name>")`.

## Reproduction steps

1. Clone this repository:

    ```sh
    git clone https://github.com/coffeebeats/example-godot-threaded-load-autoload-bug.git
    ```

2. Run the `main.tscn` scene via the editor (it's set as the project's default scene).

3. Adjust the `Main` scene's options:

- `load_on_ready`: load_on_ready controls whether this node will attempt a load within its `_ready` callback. Anecdotally, the bug is almost always observed when this is `true`, but rarely observed when `false` (and loads are instead triggered via button press).
- `use_sub_threads`: Toggles the `use_sub_threads` passed to `ResourceLoader`; this property is the primary trigger of this bug; when it's `false`, the bug is not observed.
