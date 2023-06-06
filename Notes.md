# Notes
These notes aim to provide a rough guide on how certain components (Vanilla or otherwise) work, which will help those (including myself) who are making mods leveraging/modifying the same components.

## How do Vanilla Fealty Dilemmas Work?
### Display Text in Dilemma Choice
Vanilla calls [`cm:trigger_dilemma_with_targets`](https://chadvandy.github.io/tw_modding_resources/WH3/campaign/episodic_scripting.html#function:episodic_scripting:trigger_dilemma_with_targets) in `wh2_dlc13_empire_politics.lua`, which has the following signature:
```Lua
cm:trigger_dilemma_with_targets(
  number faction cqi,
  string dilemma key,
  number target faction cqi,
  number secondary faction cqi,
  number character cqi,
  number military force cqi,
  number region cqi,
  number settlement cqi
)
```
The `dilemma key` needs to exist in `db/dilemmas_tables`. Vanilla maps each possible choice payload to the dilemma in `db/cdir_events_dilemma_payloads_tables`. 

For example, the dilemma `wh2_dlc13_emp_elector_politics_1` has four choices (note that these choices each require a corresponding `Choice Key` mapped to the `Dilemma Key` in `db/cdir_events_dilemma_choice_details_tables`). 

Observe that for `wh2_dlc13_emp_elector_politics_1`, the four choices each map to a `Payload Key` that is `TEXT_DISPLAY`, and the value is a LOOKUP, such as `LOOKUP[dummy_elector_loyalty_decrease_2]`. 

To see what this is, we search for the lookup value in `db/campaign_payload_ui_details_tables`. This will come with an icon and also a corresponding mapping to `campaign_payload_ui_details__.loc`, where the pattern naming system would map the example component `dummy_elector_loyalty_decrease_2` to `campaign_payload_ui_details_description_dummy_elector_loyalty_decrease_2` for its localisation Key. 

There we see that the value makes various references to `CcoCampaignPayloadInfoEntry`, eventually calling fields or functions such as `SecondTargetFactionNameWithIcon` or `SecondTargetFactionPooledResource`.

This `SecondTargetFaction` is related to the `secondary fation cqi` parameter in `cm:trigger_dilemma_with_targets()`.

Observe in the table `db/cdir_events_targets_tables` that there are various Target Keys, particularly `target_faction_1` and `target_faction_2` respectively. These map to the parameters `target faction cqi` and `secondary faction cqi` given by `cm:trigger_dilemma_with_targets()` mentioned above. To achieve the same effect with the [`CAMPAIGN_DILEMMA_BUILDER_SCRIPT_INTERFACE`](https://chadvandy.github.io/tw_modding_resources/WH3/scripting_doc.html#CAMPAIGN_DILEMMA_BUILDER_SCRIPT_INTERFACE), we will need to call `add_target()` and supply the ncessary Target Key and corresponding script interface. For example:
```Lua
local dilemma_builder = cm:create_dilemma_builder("example_dilemma_key");
dilemma_builder.add_target("target_faction_1",cm:get_faction("example_faction_key"));
```
The above is equivalent to giving the CQI of the faction as the parameter `target faction cqi` in `cm:trigger_dilemma_with_targets()`.

All of this, however, is just to show the text in the Dilemma choices. The actual effect is handled through listeners and scripting.

### Executing the Fealty Change
Vanilla uses a listener for `DilemmaChoiceMadeEvent` to trigger the callback for `empire_dilemma_choice(context)`. Note that the `context` does not actually contain the faction data discussed earlier; instead, those values were stored externally to `empire_political_dilemma` at the time of the dilemma generation. What `context` does contain is number of the choice selected by the player, obtained by `context:choice()`. 

Based on the choice made, the `empire_dilemma_choice()` function checks the other available data and calls the helper function `empire_modify_elector_loyalty()` to execute the fealty change accordingly.
