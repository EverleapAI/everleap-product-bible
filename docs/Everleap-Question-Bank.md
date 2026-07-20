# Everleap — the question bank

Every question the app can ask, with its answer options. Generated straight from
the database on 2026-07-20.

**This is the question bank, not anyone's answers.** No personal data appears here.

## What's actually asked

The `questions` table holds **112** rows, but the Story flow only serves **51** of them.
The rest are filtered out — wrong source sheet, or written for a Parent/Counselor
audience rather than the student. That filter lives in one place,
`apps/everleap-api/src/lib/story/storyPool.ts`, and this document applies the same rule.

| Family | Questions served |
|---|---|
| misc | 1 |
| motivations | 19 |
| skills | 19 |
| strengths | 12 |
| **Total** | **51** |

> Worth knowing: family sizes are uneven — Strengths has twelve. Anything that assumes
> a uniform count per family will be wrong, which is how a batch of badges once became
> mathematically unwinnable.

---

# Questions the Story flow serves

## misc — 1 question

### How well do you adapt to changes in your environment or tasks?

`story_misc_52_baafbd8c` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_maybe_i_could_adjust_to_minor_changes_in_routine` | Beginner: Maybe I could adjust to minor changes in routine |  |
| `basic_learn_new_tasks_when_introduced` | Basic: Learn new tasks when introduced |  |
| `skilled_quickly_adapt_to_new_technologies_or_methods` | Skilled: Quickly adapt to new technologies or methods |  |
| `advanced_lead_others_through_significant_changes` | Advanced: Lead others through significant changes |  |
| `expert_innovate_and_thrive_in_dynamic_changing_environments` | Expert: Innovate and thrive in dynamic, changing environments |  |

**Goal:** You Personality  
**Measures:** Personality Traits  
**Science:** What Color Is Your Parachute?  

## motivations — 19 questions

### What do you do outside of school/work?

*Pick anything that fits.*

`story_motivations_2_cc8d4e45` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `sports_training` | Sports / training |  |
| `art_design` | Art / design |  |
| `music_dance_theater` | Music / dance / theater |  |
| `volunteering_helping_out` | Volunteering / helping out |  |
| `working_a_job` | Working a job |  |
| `other` | Other |  |

**Goal:** What Drives You  
**Science:** Other  

### What activities or hobbies do you absolutely love doing in your free time? You know, those things that make you lose track of time because you’re having so much fun?

`story_motivations_3_2ce6044f` · type: text · weight: 50

**Goal:** What Drives You  
**Measures:** Motivations & Drivers  
**Science:** Ikigai  

### Which of these do you think you’re best at and why? Below are just examples. Answer any way you like!

`story_motivations_4_570854e8` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `visual_arts_drawing_painting_writing` | Visual Arts (drawing, painting, writing) |  |
| `performing_arts_dancing_music` | Performing Arts (dancing, music) |  |
| `sports_and_physical_activities` | Sports and Physical Activities |  |
| `solving_puzzles_and_games` | Solving Puzzles and Games |  |
| `helping_friends_and_family` | Helping Friends and Family |  |

**Goal:** What Drives You  
**Measures:** Aptitude & Skills  
**Science:** Ikigai  

### What subjects or topics do you find yourself reading or learning about independently on your own time?

`story_motivations_5_155dc2f9` · type: text · weight: 50

**Goal:** What Drives You  
**Measures:** Motivations & Drivers  
**Science:** Ikigai  

### When you’re faced with a challenge, how do you usually react? Below are examples. Feel free to add your own ideas!

`story_motivations_6_0012fac3` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `take_charge` | Take charge |  |
| `look_for_creative_solutions` | Look for creative solutions |  |
| `seek_advice_from_others` | Seek advice from others |  |
| `take_some_time_to_think_it_through` | Take some time to think it through |  |

**Goal:** What Drives You  
**Measures:** Personality Traits  
**Science:** Ikigai  

### Now, let’s talk about how you interact with others. Which of these best describes you? Feel free to describe your own!

`story_motivations_7_d30fd6ba` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `i_m_the_leader_of_my_group` | I’m the leader of my group |  |
| `i_m_the_creative_thinker` | I’m the creative thinker |  |
| `i_m_the_supportive_friend` | I’m the supportive friend |  |
| `i_m_the_peacekeeper` | I’m the peacekeeper |  |

**Goal:** What Drives You  
**Measures:** Social Orientation  
**Science:** Ikigai  

### What do you like to do when you're on your own? Do you have any favorite solo activities?

`story_motivations_8_789a2e08` · type: text · weight: 50

**Goal:** What Drives You  
**Measures:** Motivations & Drivers  
**Science:** Ikigai  

### Now imagine your perfect day. What activities would make it the best?

`story_motivations_9_c06e0d70` · type: text · weight: 50

**Goal:** What Drives You  
**Measures:** Motivations & Drivers  
**Science:** Ikigai  

### What activities make you feel the most confident and proud of yourself? Below are examples, but feel free to add your own.

`story_motivations_10_0eb93fa9` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `leading_a_group_project` | Leading a group project |  |
| `helping_someone_solve_a_problem` | Helping someone solve a problem |  |
| `creating_something_new` | Creating something new |  |
| `supporting_a_friend_in_need` | Supporting a friend in need |  |

**Goal:** What Drives You  
**Measures:** Aptitude & Skills  
**Science:** Ikigai  

### If you could have any job in the world, what would it be and why? Feel free to share whatever comes to mind.

`story_motivations_11_69e37649` · type: text · weight: 50

**Goal:** What Drives You  
**Measures:** Aspirations & Life Goals  
**Science:** Ikigai  

### Let's think about some different areas you could explore. Which of these excites you the most? Make up your own if you like.

`story_motivations_12_ce8d85e2` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `arts_and_entertainment` | Arts and Entertainment |  |
| `science_and_technology` | Science and Technology |  |
| `business_and_entrepreneurship` | Business and Entrepreneurship |  |
| `social_services` | Social Services |  |

**Goal:** What Drives You  
**Measures:** Motivations & Drivers  
**Science:** Ikigai  

### Who in your life do you really look up to? Why?

`story_motivations_13_da3a95a4` · type: text · weight: 50

**Goal:** What Drives You  
**Measures:** Aspirations & Life Goals  
**Science:** Ikigai  

### If you could spend a day with anyone, living or dead, who would it be? What would you talk about?

`story_motivations_14_73c1d2d1` · type: text · weight: 50

**Goal:** What Drives You  
**Measures:** Aspirations & Life Goals  
**Science:** Ikigai  

### How do you like to contribute to your community or help others? Here are some options, but feel free to add your own.

`story_motivations_15_9eeccd4e` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `volunteering_for_local_organizations` | Volunteering for local organizations |  |
| `helping_friends_and_family` | Helping friends and family |  |
| `participating_in_community_events` | Participating in community events |  |
| `advocating_for_social_causes` | Advocating for social causes |  |

**Goal:** What Drives You  
**Measures:** Values & Beliefs  
**Science:** Ikigai  

### When learning new things, how to you prefer to learn?

`story_motivations_16_d3bff909` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `reading` | Reading |  |
| `hands_on` | Hands-on |  |
| `online_research_or_courses` | Online research or courses |  |

**Goal:** What Drives You  
**Measures:** Learning & Thinking Style  
**Science:** Ikigai  

### What is a talent or skill of yours that you'd like to see more of in the world? How could you use it to help others?

`story_motivations_17_ba235a9f` · type: text · weight: 50

**Goal:** What Drives You  
**Measures:** Aptitude & Skills  
**Science:** Ikigai  

### When you imagine your future, what kind of person do you want to be?

`story_motivations_18_e70b382a` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `a_leader_who_inspires_others` | A leader who inspires others |  |
| `a_creative_person_making_a_difference` | A creative person making a difference |  |
| `a_dependable_and_supportive_friend` | A dependable and supportive friend |  |
| `an_expert_in_something_you_love` | An expert in something you love |  |
| `a_calm_and_balanced_individual` | A calm and balanced individual |  |

**Goal:** What Drives You  
**Measures:** Aspirations & Life Goals  
**Science:** Ikigai  

### What are your top three values that guide your decisions and actions?

*Examples: Honesty, Kindness, Responsibility, Creativity, Ambition, Empathy*

`story_motivations_19_8d0401aa` · type: text · weight: 50

**Goal:** What Drives You  
**Measures:** Values & Beliefs  
**Science:** Ikigai  

### Describe a time when you had to overcome a significant obstacle. What did you learn from the experience?

`story_motivations_20_f114e332` · type: text · weight: 50

**Goal:** What Drives You  
**Measures:** Personality Traits  
**Science:** Ikigai  

## skills — 19 questions

### How confident are you in identifying the root cause of a problem and finding a solution?

`story_skills_33_62abfc91` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_i_can_follow_instructions_to_fix_a_simple_issue` | Beginner: I can follow instructions to fix a simple issue. |  |
| `basic_identify_the_source_of_a_problem_and_suggest_a_solution` | Basic: Identify the source of a problem and suggest a solution. |  |
| `skilled_develop_a_plan_to_address_a_complex_problem` | Skilled: Develop a plan to address a complex problem. |  |
| `advanced_implement_solutions_to_prevent_future_issues` | Advanced: Implement solutions to prevent future issues, |  |
| `expert_innovate_new_methods_to_solve_problems_in_unique_situations` | Expert: Innovate new methods to solve problems in unique situations, |  |

**Goal:** Your Skills  
**Measures:** Learning & Thinking Style  
**Science:** What Color Is Your Parachute?  

### How well do you communicate with others in different settings?

`story_skills_34_1b44a447` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_i_sometimes_talk_to_classmates_or_teachers_and_maybe_i_ve_answered_a_phone_call_or_passed_along_a_message` | Beginner: I sometimes talk to classmates or teachers, and maybe I’ve answered a phone call or passed along a message. |  |
| `basic_i_can_write_a_clear_and_respectful_email_to_a_teacher_or_respond_appropriately_in_class_discussions` | Basic: I can write a clear and respectful email to a teacher or respond appropriately in class discussions. |  |
| `skilled_i_ve_led_a_group_discussion_or_helped_coordinate_a_group_project` | Skilled: I’ve led a group discussion or helped coordinate a group project. |  |
| `advanced_i_ve_persuaded_others_during_a_debate_resolved_a_disagreement_in_a_group_project_or_advocated_for_myself_or_others_in_a_school_or_job_setting` | Advanced: I’ve persuaded others during a debate, resolved a disagreement in a group project, or advocated for myself or others in a school or job setting. |  |
| `expert_i_ve_helped_mediate_conflicts_between_peers_led_teams_or_clubs_effectively_or_facilitated_productive_discussions_in_challenging_situations` | Expert: I’ve helped mediate conflicts between peers, led teams or clubs effectively, or facilitated productive discussions in challenging situations. |  |

**Goal:** Your Skills  
**Measures:** Social Orientation  
**Science:** What Color Is Your Parachute?  

### How effectively do you work with others to achieve a common goal?

`story_skills_35_5bac8adf` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_i_ve_helped_a_group_by_doing_simple_tasks_like_handing_out_materials_or_following_instructions` | Beginner: I’ve helped a group by doing simple tasks, like handing out materials or following instructions. |  |
| `basic_i_share_my_ideas_in_group_projects_or_class_discussions_and_support_my_teammates` | Basic: I share my ideas in group projects or class discussions and support my teammates. |  |
| `skilled_i_actively_collaborate_on_school_projects_clubs_or_sports_teams_to_complete_shared_goals` | Skilled: I actively collaborate on school projects, clubs, or sports teams to complete shared goals. |  |
| `advanced_i_ve_taken_the_lead_on_group_assignments_or_helped_keep_my_team_organized_and_motivated` | Advanced: I’ve taken the lead on group assignments or helped keep my team organized and motivated. |  |
| `expert_i_ve_guided_teams_from_different_groups_like_clubs_classes_or_volunteer_organizations_to_work_together_and_succeed` | Expert: I’ve guided teams from different groups (like clubs, classes, or volunteer organizations) to work together and succeed. |  |

**Goal:** Your Skills  
**Measures:** Social Orientation  
**Science:** What Color Is Your Parachute?  

### How proficient are you in managing time and resources?

`story_skills_36_59832352` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_i_try_to_keep_my_backpack_locker_or_workspace_tidy` | Beginner: I try to keep my backpack, locker, or workspace tidy. |  |
| `basic_i_use_a_planner_or_to_do_list_to_stay_on_top_of_homework_or_personal_tasks` | Basic: I use a planner or to-do list to stay on top of homework or personal tasks. |  |
| `skilled_i_can_juggle_multiple_responsibilities_like_school_a_part_time_job_and_extracurricular_activities` | Skilled: I can juggle multiple responsibilities like school, a part-time job, and extracurricular activities. |  |
| `advanced_i_ve_helped_plan_events_like_school_fundraisers_club_meetings_or_group_trips` | Advanced: I’ve helped plan events like school fundraisers, club meetings, or group trips. |  |
| `expert_i_ve_created_systems_like_calendars_or_checklists_to_keep_long_term_projects_or_groups_organized_and_on_track` | Expert: I’ve created systems (like calendars or checklists) to keep long-term projects or groups organized and on track. |  |

**Goal:** Your Skills  
**Measures:** Aptitude & Skills, Personality Traits  
**Science:** What Color Is Your Parachute?  

### How strong are your creative abilities in generating new ideas or solutions?

`story_skills_37_7fc37fbe` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_i_like_to_draw_doodle_or_think_of_fun_ideas_in_my_free_time` | Beginner: I like to draw, doodle, or think of fun ideas in my free time. |  |
| `basic_i_ve_made_simple_designs_or_creative_projects_for_school_assignments` | Basic: I’ve made simple designs or creative projects for school assignments. |  |
| `skilled_i_ve_come_up_with_unique_ideas_or_creative_solutions_during_class_club_activities_or_personal_projects` | Skilled: I’ve come up with unique ideas or creative solutions during class, club activities, or personal projects. |  |
| `advanced_i_ve_designed_detailed_projects_written_stories_composed_music_or_made_original_content_that_others_noticed` | Advanced: I’ve designed detailed projects, written stories, composed music, or made original content that others noticed. |  |
| `expert_i_regularly_create_innovative_work_or_ideas_that_inspire_or_influence_others_like_in_art_writing_leadership_or_tech` | Expert: I regularly create innovative work or ideas that inspire or influence others (like in art, writing, leadership, or tech). |  |

**Goal:** Your Skills  
**Measures:** Creative & Aesthetic Orientation  
**Science:** What Color Is Your Parachute?  

### How effective are you in providing service to customers or clients?

`story_skills_38_0cebc9d5` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_i_can_greet_people_politely_and_help_with_simple_questions_or_tasks_like_at_a_school_event_store_or_front_office` | Beginner: I can greet people politely and help with simple questions or tasks (like at a school event, store, or front office). |  |
| `basic_i_ve_handled_basic_requests_or_answered_questions_in_a_calm_and_respectful_way_like_in_a_part_time_job_or_volunteer_role` | Basic: I’ve handled basic requests or answered questions in a calm and respectful way (like in a part-time job or volunteer role). |  |
| `skilled_i_ve_helped_solve_problems_or_complaints_while_keeping_a_positive_attitude_and_making_sure_the_person_felt_heard` | Skilled: I’ve helped solve problems or complaints while keeping a positive attitude and making sure the person felt heard. |  |
| `advanced_i_ve_mentored_new_team_members_and_shown_others_how_to_give_good_service_or_helped_improve_how_our_group_interacts_with_people` | Advanced: I’ve mentored new team members and shown others how to give good service or helped improve how our group interacts with people. |  |
| `expert_i_ve_come_up_with_new_ways_to_make_customers_or_community_members_feel_supported_and_shared_those_ideas_with_others_to_improve_the_experience_overall` | Expert: I’ve come up with new ways to make customers or community members feel supported, and shared those ideas with others to improve the experience overall. |  |

**Goal:** Your Skills  
**Measures:** Social Orientation  
**Science:** What Color Is Your Parachute?  

### How confident are you in working with technical tools and machinery?

`story_skills_39_3c4ed335` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_i_can_change_a_lightbulb` | Beginner: I can change a lightbulb. |  |
| `basic_i_can_use_a_power_drill_to_hang_a_picture` | Basic: I can use a power drill to hang a picture. |  |
| `skilled_i_can_repair_a_broken_appliance` | Skilled: I can repair a broken appliance. |  |
| `advanced_i_can_troubleshoot_and_fix_mechanical_issues_on_a_vehicle` | Advanced: I can troubleshoot and fix mechanical issues on a vehicle. |  |
| `expert_i_can_design_and_build_a_custom_piece_of_machinery` | Expert: I can design and build a custom piece of machinery. |  |

**Goal:** Your Skills  
**Measures:** Aptitude & Skills  
**Science:** What Color Is Your Parachute?  

### How well do you lead and manage others?

*Beginner: I’ve stepped up to lead a small part of a group task when needed.*

`story_skills_40_2be1e162` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `basic_i_can_organize_a_group_project_assign_tasks_and_keep_people_on_track` | Basic: I can organize a group project, assign tasks, and keep people on track. |  |
| `skilled_i_ve_led_a_team_to_meet_a_deadline_or_complete_a_challenging_goal_like_in_a_class_club_or_job` | Skilled: I’ve led a team to meet a deadline or complete a challenging goal (like in a class, club, or job). |  |
| `advanced_i_ve_helped_teammates_improve_their_skills_or_confidence_by_mentoring_or_coaching_them` | Advanced: I’ve helped teammates improve their skills or confidence by mentoring or coaching them. |  |
| `expert_i_ve_taken_the_lead_during_big_changes_in_a_group_club_or_organization_and_helped_guide_others_through_it_successfully` | Expert: I’ve taken the lead during big changes in a group, club, or organization and helped guide others through it successfully. |  |

**Goal:** Your Skills  
**Measures:** Social Orientation  
**Science:** What Color Is Your Parachute?  

### How comfortable are you with analyzing data or information to make decisions?

*Beginner: I’ve helped collect or organize basic information for a school project or club.*

`story_skills_41_449dc71e` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `basic_i_can_look_at_data_like_a_survey_or_grades_and_notice_simple_patterns_or_trends` | Basic: I can look at data (like a survey or grades) and notice simple patterns or trends. |  |
| `skilled_i_ve_made_informed_decisions_using_charts_graphs_or_research_like_choosing_a_fundraising_method_or_comparing_job_offers` | Skilled: I’ve made informed decisions using charts, graphs, or research (like choosing a fundraising method or comparing job offers). |  |
| `advanced_i_ve_created_reports_or_presentations_using_data_to_support_my_ideas_or_recommendations` | Advanced: I’ve created reports or presentations using data to support my ideas or recommendations. |  |
| `expert_i_ve_used_in_depth_analysis_to_guide_a_strategy_or_plan_for_a_team_event_or_business_project` | Expert: I’ve used in-depth analysis to guide a strategy or plan for a team, event, or business project. |  |

**Goal:** Your Skills  
**Measures:** Aptitude & Skills  
**Science:** What Color Is Your Parachute?  

### How skilled are you in construction-related tasks?

*Beginner: I can hang a picture or help put together a piece of furniture.*

`story_skills_42_b91c2606` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `basic_i_can_safely_use_basic_tools_to_do_small_repairs_like_fixing_a_squeaky_hinge_or_tightening_screws` | Basic: I can safely use basic tools to do small repairs (like fixing a squeaky hinge or tightening screws). |  |
| `skilled_i_ve_completed_hands_on_tasks_like_fixing_a_leak_painting_a_room_or_replacing_light_fixtures` | Skilled: I’ve completed hands-on tasks like fixing a leak, painting a room, or replacing light fixtures. |  |
| `advanced_i_ve_taken_on_bigger_projects_like_building_a_shed_helping_with_home_repairs_or_setting_up_a_workspace` | Advanced: I’ve taken on bigger projects like building a shed, helping with home repairs, or setting up a workspace. |  |
| `expert_i_ve_designed_and_built_complex_projects_from_start_to_finish_possibly_with_blueprints_power_tools_or_construction_planning` | Expert: I’ve designed and built complex projects from start to finish, possibly with blueprints, power tools, or construction planning. |  |

**Goal:** Your Skills  
**Measures:** Aptitude & Skills  
**Science:** What Color Is Your Parachute?  

### How proficient are you in managing budgets or financial resources?

`story_skills_43_a3b3866a` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_i_ve_tracked_my_personal_spending_or_started_saving_for_something_like_a_phone_trip_or_college` | Beginner: I’ve tracked my personal spending or started saving for something like a phone, trip, or college. |  |
| `basic_i_ve_made_a_simple_budget_for_a_school_event_club_activity_or_personal_project` | Basic: I’ve made a simple budget for a school event, club activity, or personal project. |  |
| `skilled_i_ve_helped_manage_money_for_a_fundraiser_student_group_or_small_business_like_babysitting_or_a_side_hustle` | Skilled: I’ve helped manage money for a fundraiser, student group, or small business (like babysitting or a side hustle). |  |
| `advanced_i_ve_created_financial_plans_compared_options_or_forecasted_expenses_for_larger_projects_or_goals` | Advanced: I’ve created financial plans, compared options, or forecasted expenses for larger projects or goals. |  |
| `expert_i_ve_overseen_the_full_budget_for_a_group_club_or_event_and_made_key_financial_decisions` | Expert: I’ve overseen the full budget for a group, club, or event, and made key financial decisions. |  |

**Goal:** Your Skills  
**Measures:** Aptitude & Skills  
**Science:** What Color Is Your Parachute?  

### How well can you teach or train others?

*Beginner: I’ve helped a friend or classmate understand something they were struggling with.*

`story_skills_44_fd208be6` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `basic_i_ve_tutored_someone_in_a_subject_i_m_strong_in_like_math_or_writing` | Basic: I’ve tutored someone in a subject I’m strong in, like math or writing. |  |
| `skilled_i_ve_led_a_small_group_in_learning_a_new_skill_like_in_a_club_sport_or_job_training` | Skilled: I’ve led a small group in learning a new skill (like in a club, sport, or job training). |  |
| `advanced_i_ve_created_lessons_training_guides_or_workshops_to_help_others_learn` | Advanced: I’ve created lessons, training guides, or workshops to help others learn. |  |
| `expert_i_ve_designed_full_educational_programs_lesson_plans_or_training_systems_and_helped_others_implement_them` | Expert: I’ve designed full educational programs, lesson plans, or training systems and helped others implement them. |  |

**Goal:** Your Skills  
**Measures:** Aptitude & Skills  
**Science:** What Color Is Your Parachute?  

### How confident are you in managing projects from start to finish?

`story_skills_45_aa4c0511` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_maybe_i_could_assist_with_tasks_on_a_small_project` | Beginner: Maybe I could assist with tasks on a small project |  |
| `basic_plan_and_execute_a_simple_project` | Basic: Plan and execute a simple project |  |
| `skilled_manage_all_aspects_of_a_mid_sized_project` | Skilled: Manage all aspects of a mid-sized project |  |
| `advanced_lead_a_large_project` | Advanced: Lead a large project |  |
| `expert_oversee_complex_multi_phase_projects` | Expert: Oversee complex, multi-phase projects |  |

**Goal:** Your Skills  
**Measures:** Aptitude & Skills  
**Science:** What Color Is Your Parachute?  

### How effective are you in promoting products or services?

`story_skills_46_772bad68` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_maybe_i_could_explain_the_benefits_of_a_product_to_a_friend` | Beginner: Maybe I could explain the benefits of a product to a friend |  |
| `basic_help_with_promotions_at_a_school_or_community_event` | Basic: Help with promotions at a school or community event |  |
| `skilled_sell_products_or_services_in_a_retail_environment` | Skilled: Sell products or services in a retail environment |  |
| `advanced_develop_marketing_campaigns_for_a_small_business` | Advanced: Develop marketing campaigns for a small business |  |
| `expert_create_and_execute_strategic_marketing_plans_for_large_organizations` | Expert: Create and execute strategic marketing plans for large organizations |  |

**Goal:** Your Skills  
**Measures:** Aptitude & Skills  
**Science:** What Color Is Your Parachute?  

### How well do you understand and apply health and safety practices?

`story_skills_47_7b0c7aab` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_i_could_follow_basic_safety_rules_in_the_workplace` | Beginner: I could follow basic safety rules in the workplace |  |
| `basic_use_personal_protective_equipment_correctly` | Basic: Use personal protective equipment correctly |  |
| `skilled_conduct_safety_inspections_and_report_hazards` | Skilled: Conduct safety inspections and report hazards |  |
| `advanced_implement_safety_protocols_and_train_others` | Advanced: Implement safety protocols and train others |  |
| `expert_develop_comprehensive_health_and_safety_programs` | Expert: Develop comprehensive health and safety programs |  |

**Goal:** Your Skills  
**Measures:** Aptitude & Skills  
**Science:** What Color Is Your Parachute?  

### How proficient are you in conducting research to gather information?

`story_skills_48_3952d94a` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_find_basic_information_online` | Beginner: Find basic information online |  |
| `basic_conduct_research_for_a_school_project` | Basic: Conduct research for a school project |  |
| `skilled_use_multiple_sources_to_compile_detailed_reports` | Skilled: Use multiple sources to compile detailed reports |  |
| `advanced_analyze_research_findings_and_present_conclusions` | Advanced: Analyze research findings and present conclusions |  |
| `expert_conduct_original_research_and_publish_findings` | Expert: Conduct original research and publish findings |  |

**Goal:** Your Skills  
**Measures:** Aptitude & Skills  
**Science:** What Color Is Your Parachute?  

### How comfortable are you in interacting with others in a professional setting?

`story_skills_49_d84fff7d` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_greet_and_engage_in_small_talk_with_colleagues` | Beginner: Greet and engage in small talk with colleagues |  |
| `basic_participate_in_group_discussions` | Basic: Participate in group discussions |  |
| `skilled_build_and_maintain_professional_relationships` | Skilled: Build and maintain professional relationships |  |
| `advanced_negotiate_and_collaborate_on_complex_tasks` | Advanced: Negotiate and collaborate on complex tasks |  |
| `expert_manage_relationships_with_clients_partners_and_stakeholders` | Expert: Manage relationships with clients, partners, and stakeholders |  |

**Goal:** Your Skills  
**Measures:** Social Orientation  
**Science:** What Color Is Your Parachute?  

### How skilled are you in organizing and managing logistics?

`story_skills_50_454dcb05` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_maybe_i_could_organize_a_small_event_or_gathering` | Beginner: Maybe I could organize a small event or gathering |  |
| `basic_coordinate_the_delivery_of_supplies_for_a_project` | Basic: Coordinate the delivery of supplies for a project |  |
| `skilled_manage_inventory_and_supply_chains_for_a_business` | Skilled: Manage inventory and supply chains for a business |  |
| `advanced_oversee_logistics_for_large_scale_events_or_operations` | Advanced: Oversee logistics for large-scale events or operations |  |
| `expert_develop_and_optimize_complex_logistical_systems` | Expert: Develop and optimize complex logistical systems |  |

**Goal:** Your Skills  
**Measures:** Aptitude & Skills  
**Science:** What Color Is Your Parachute?  

### How comfortable are you with using various software tools?

`story_skills_51_e962fa0a` · type: single_select · weight: 50

| Option | Label | Description |
|---|---|---|
| `beginner_use_basic_word_processing_and_spreadsheet_tools` | Beginner: Use basic word processing and spreadsheet tools |  |
| `basic_create_presentations_and_simple_databases` | Basic: Create presentations and simple databases |  |
| `skilled_utilize_specialized_software_for_specific_tasks` | Skilled: Utilize specialized software for specific tasks |  |
| `advanced_integrate_multiple_software_tools_for_efficient_workflows` | Advanced: Integrate multiple software tools for efficient workflows |  |
| `expert_develop_custom_software_solutions_or_advanced_integrations` | Expert: Develop custom software solutions or advanced integrations |  |

**Goal:** Your Skills  
**Measures:** Aptitude & Skills  
**Science:** What Color Is Your Parachute?  

## strengths — 12 questions

### Think about something fun you’ve worked on before, like a school project or a hobby. What made it so awesome for you?

`story_strengths_21_70a9ab9b` · type: text · weight: 50

**Goal:** Your Strengths  
**Measures:** Motivations & Drivers  
**Science:** Enneagram  

### Can you remember a time when you learned something super fast? What was it, and why do you think you got the hang of it so quickly?

`story_strengths_22_911dae2d` · type: text · weight: 50

**Goal:** Your Strengths  
**Measures:** Aptitude & Skills  
**Science:** Enneagram  

### Think about a time when you faced a tough challenge. What kinds of skills did you use to get through it?

`story_strengths_23_ebe8633f` · type: text · weight: 50

**Goal:** Your Strengths  
**Measures:** Personality Traits  
**Science:** Enneagram  

### When you’re working on a group project or with friends, what role do you usually take on? Why do you think that is?

`story_strengths_24_63533f98` · type: text · weight: 50

**Goal:** Your Strengths  
**Measures:** Social Orientation  
**Science:** Enneagram  

### Think about a time when you really understood what someone else was feeling. How did you respond to their emotions, and what happened after?

`story_strengths_25_d8f8d4f5` · type: text · weight: 50

**Goal:** Your Strengths  
**Measures:** Emotional Style  
**Science:** Enneagram  

### Think about a time when you noticed a problem that others didn’t see. How did you find it, and what did you do to fix it?

`story_strengths_26_a738a9e6` · type: text · weight: 50

**Goal:** Your Strengths  
**Measures:** Aptitude & Skills  
**Science:** Enneagram  

### Think about a time when you took initiative to take the lead on a project. What made you want to step up?

`story_strengths_27_546a82fd` · type: text · weight: 50

**Goal:** Your Strengths  
**Measures:** Social Orientation  
**Science:** Enneagram  

### Think about a past project or team that you were on that succeeded (in school, sports, or family for example). What was your role, and how did you help the team succeed?

`story_strengths_28_f027c2db` · type: text · weight: 50

**Goal:** Your Strengths  
**Measures:** Social Orientation  
**Science:** Enneagram  

### Think about a time when you had to adapt quickly to a big change, like a new school or a different team. How did you handle it, and what happened in the end?

`story_strengths_29_6db9f26e` · type: text · weight: 50

**Goal:** Your Strengths  
**Measures:** Personality Traits  
**Science:** Enneagram  

### Think about a time when communication was super important to get something done. What was going on, and how did your way of talking or listening help?

`story_strengths_30_de3a33b0` · type: text · weight: 50

**Goal:** Your Strengths  
**Measures:** Social Orientation  
**Science:** Enneagram  

### Think about something you’re really proud of (school, extracurriculars). What challenges did you overcome to achieve this win?

`story_strengths_31_2b624fb7` · type: text · weight: 50

**Goal:** Your Strengths  
**Measures:** Motivations & Drivers  
**Science:** Enneagram  

### Can you remember a time when you convinced others to see things your way, like during a group project or a debate? What did you do to persuade them?

`story_strengths_32_f7e6d777` · type: text · weight: 50

**Goal:** Your Strengths  
**Measures:** Social Orientation  
**Science:** Enneagram  

---

# In the table, but never asked (61)

These sit in the `questions` table but the Story flow filters them out. Listed so
nobody documents a question the product never shows.

| Prompt | Family | Source sheet | Audience |
|---|---|---|---|
| What do you do outside of school/work? Pick anything that fits.  Sports / training Art / design Music / dance / theater Volunteering / helping out Working a job Other | motivations | Question Schema v1.1 |  |
| What activities or hobbies do you absolutely love doing in your free time? You know, those things that make you lose track of time because you’re having so much fun? | motivations | Question Schema v1.1 | Child/Student/Self |
| Which of these do you think you’re best at and why? Below are just examples. Answer any way you like!  Visual Arts (drawing, painting, writing) Performing Arts (dancing, music) Sports and Physical Activities Solving Puzzles and Games Helping Friends and Family | motivations | Question Schema v1.1 | Child/Student/Self |
| When you’re faced with a challenge, how do you usually react? Below are examples. Feel free to add your own ideas!  Take charge Look for creative solutions Seek advice from others Take some time to think it through | motivations | Question Schema v1.1 | Child/Student/Self |
| Now, let’s talk about how you interact with others. Which of these best describes you? Feel free to describe your own!   I’m the leader of my group I’m the creative thinker I’m the supportive friend  I’m the peacekeeper | motivations | Question Schema v1.1 | Child/Student/Self |
| If you could have any job in the world, what would it be and why? Feel free to share whatever comes to mind. | motivations | Question Schema v1.1 | Child/Student/Self |
| What does [child]'s love doing? | motivations | Question Schema v1.1 | Parent/Counselor |
| What is a talent or skill of yours that you'd like to see more of in the world? How could you use it to help others? | motivations | Question Schema v1.1 | Child/Student/Self |
| What subjects or topics do you find yourself reading or learning about independently on your own time? | motivations | Question Schema v1.1 | Child/Student/Self |
| What do you like to do when you're on your own? Do you have any favorite solo activities? | motivations | Question Schema v1.1 | Child/Student/Self |
| Now imagine your perfect day. What activities would make it the best? | motivations | Question Schema v1.1 | Child/Student/Self |
| What activities make you feel the most confident and proud of yourself? Below are examples, but feel free to add your own.  Leading a group project  Helping someone solve a problem  Creating something new  Supporting a friend in need | motivations | Question Schema v1.1 | Child/Student/Self |
| Let's think about some different areas you could explore. Which of these excites you the most? Make up your own if you like.  Arts and Entertainment Science and Technology  Business and Entrepreneurship  Social Services | motivations | Question Schema v1.1 | Child/Student/Self |
| Who in your life do you really look up to? Why? | motivations | Question Schema v1.1 | Child/Student/Self |
| If you could spend a day with anyone, living or dead, who would it be? What would you talk about? | motivations | Question Schema v1.1 | Child/Student/Self |
| How do you like to contribute to your community or help others? Here are some options, but feel free to add your own.  Volunteering for local organizations  Helping friends and family  Participating in community events  Advocating for social causes | motivations | Question Schema v1.1 | Child/Student/Self |
| When learning new things, how to you prefer to learn?   Reading Hands-on Online research or courses | motivations | Question Schema v1.1 | Child/Student/Self |
| When you imagine your future, what kind of person do you want to be?   A leader who inspires others  A creative person making a difference  A dependable and supportive friend  An expert in something you love  A calm and balanced individual | motivations | Question Schema v1.1 | Child/Student/Self |
| What are your top three values that guide your decisions and actions?  Examples: Honesty, Kindness, Responsibility, Creativity, Ambition, Empathy | motivations | Question Schema v1.1 | Child/Student/Self |
| Describe a time when you had to overcome a significant obstacle. What did you learn from the experience? | motivations | Question Schema v1.1 | Child/Student/Self |
| What do you naturally spend time on? | onboarding |  |  |
| How much of a plan do you have right now? | onboarding |  |  |
| What’s one idea you already have? | onboarding |  |  |
| Pick one. | onboarding |  |  |
| What should I call you? | onboarding |  |  |
| What’s actually on your radar after high school? | onboarding |  |  |
| Where are you right now? | onboarding |  |  |
| Want to add your zip code? | onboarding |  |  |
| How confident are you in identifying the root cause of a problem and finding a solution?  Choose one of the following:  Beginner: I can follow instructions to fix a simple issue. Basic: Identify the source of a problem and suggest a solution. Skilled: Develop a plan to address a complex problem. Advanced: Implement solutions to prevent future issues, Expert: Innovate new methods to solve problems in unique situations, | skills | Question Schema v1.1 | Child/Student/Self |
| How well do you communicate with others in different settings?  Choose one of the following:  Beginner: I sometimes talk to classmates or teachers, and maybe I’ve answered a phone call or passed along a message.  Basic: I can write a clear and respectful email to a teacher or respond appropriately in class discussions.  Skilled: I’ve led a group discussion or helped coordinate a group project.  Advanced: I’ve persuaded others during a debate, resolved a disagreement in a group project, or advocated for myself or others in a school or job setting.  Expert: I’ve helped mediate conflicts between peers, led teams or clubs effectively, or facilitated productive discussions in challenging situations. | skills | Question Schema v1.1 | Child/Student/Self |
| How effectively do you work with others to achieve a common goal?  Choose one of the following:  Beginner: I’ve helped a group by doing simple tasks, like handing out materials or following instructions.  Basic: I share my ideas in group projects or class discussions and support my teammates.  Skilled: I actively collaborate on school projects, clubs, or sports teams to complete shared goals.  Advanced: I’ve taken the lead on group assignments or helped keep my team organized and motivated.  Expert: I’ve guided teams from different groups (like clubs, classes, or volunteer organizations) to work together and succeed. | skills | Question Schema v1.1 | Child/Student/Self |
| How proficient are you in managing time and resources?  Choose one of the following:  Beginner: I try to keep my backpack, locker, or workspace tidy.  Basic: I use a planner or to-do list to stay on top of homework or personal tasks.  Skilled: I can juggle multiple responsibilities like school, a part-time job, and extracurricular activities.  Advanced: I’ve helped plan events like school fundraisers, club meetings, or group trips.  Expert: I’ve created systems (like calendars or checklists) to keep long-term projects or groups organized and on track. | skills | Question Schema v1.1 | Child/Student/Self |
| How strong are your creative abilities in generating new ideas or solutions?  Beginner: I like to draw, doodle, or think of fun ideas in my free time.  Basic: I’ve made simple designs or creative projects for school assignments.  Skilled: I’ve come up with unique ideas or creative solutions during class, club activities, or personal projects.  Advanced: I’ve designed detailed projects, written stories, composed music, or made original content that others noticed.  Expert: I regularly create innovative work or ideas that inspire or influence others (like in art, writing, leadership, or tech). | skills | Question Schema v1.1 | Child/Student/Self |
| How effective are you in providing service to customers or clients?  Beginner: I can greet people politely and help with simple questions or tasks (like at a school event, store, or front office).  Basic: I’ve handled basic requests or answered questions in a calm and respectful way (like in a part-time job or volunteer role).  Skilled: I’ve helped solve problems or complaints while keeping a positive attitude and making sure the person felt heard.  Advanced: I’ve mentored new team members and shown others how to give good service or helped improve how our group interacts with people.  Expert: I’ve come up with new ways to make customers or community members feel supported, and shared those ideas with others to improve the experience overall. | skills | Question Schema v1.1 | Child/Student/Self |
| How confident are you in working with technical tools and machinery?  Beginner: I can change a lightbulb. Basic: I can use a power drill to hang a picture. Skilled: I can repair a broken appliance. Advanced: I can troubleshoot and fix mechanical issues on a vehicle. Expert: I can design and build a custom piece of machinery. | skills | Question Schema v1.1 | Child/Student/Self |
| How well do you lead and manage others? Beginner: I’ve stepped up to lead a small part of a group task when needed.  Basic: I can organize a group project, assign tasks, and keep people on track.  Skilled: I’ve led a team to meet a deadline or complete a challenging goal (like in a class, club, or job).  Advanced: I’ve helped teammates improve their skills or confidence by mentoring or coaching them.  Expert: I’ve taken the lead during big changes in a group, club, or organization and helped guide others through it successfully. | skills | Question Schema v1.1 | Child/Student/Self |
| How comfortable are you with analyzing data or information to make decisions? Beginner: I’ve helped collect or organize basic information for a school project or club.  Basic: I can look at data (like a survey or grades) and notice simple patterns or trends.  Skilled: I’ve made informed decisions using charts, graphs, or research (like choosing a fundraising method or comparing job offers).  Advanced: I’ve created reports or presentations using data to support my ideas or recommendations.  Expert: I’ve used in-depth analysis to guide a strategy or plan for a team, event, or business project. | skills | Question Schema v1.1 | Child/Student/Self |
| How skilled are you in construction-related tasks? Beginner: I can hang a picture or help put together a piece of furniture.  Basic: I can safely use basic tools to do small repairs (like fixing a squeaky hinge or tightening screws).  Skilled: I’ve completed hands-on tasks like fixing a leak, painting a room, or replacing light fixtures.  Advanced: I’ve taken on bigger projects like building a shed, helping with home repairs, or setting up a workspace.  Expert: I’ve designed and built complex projects from start to finish, possibly with blueprints, power tools, or construction planning. | skills | Question Schema v1.1 | Child/Student/Self |
| How proficient are you in managing budgets or financial resources?  Beginner: I’ve tracked my personal spending or started saving for something like a phone, trip, or college.  Basic: I’ve made a simple budget for a school event, club activity, or personal project.  Skilled: I’ve helped manage money for a fundraiser, student group, or small business (like babysitting or a side hustle).  Advanced: I’ve created financial plans, compared options, or forecasted expenses for larger projects or goals.  Expert: I’ve overseen the full budget for a group, club, or event, and made key financial decisions. | skills | Question Schema v1.1 | Child/Student/Self |
| How well can you teach or train others? Beginner: I’ve helped a friend or classmate understand something they were struggling with.  Basic: I’ve tutored someone in a subject I’m strong in, like math or writing.  Skilled: I’ve led a small group in learning a new skill (like in a club, sport, or job training).  Advanced: I’ve created lessons, training guides, or workshops to help others learn.  Expert: I’ve designed full educational programs, lesson plans, or training systems and helped others implement them. | skills | Question Schema v1.1 | Child/Student/Self |
| How confident are you in managing projects from start to finish?  Beginner: Maybe I could assist with tasks on a small project Basic: Plan and execute a simple project Skilled: Manage all aspects of a mid-sized project Advanced: Lead a large project Expert: Oversee complex, multi-phase projects | skills | Question Schema v1.1 | Child/Student/Self |
| How effective are you in promoting products or services? Beginner: Maybe I could explain the benefits of a product to a friend Basic: Help with promotions at a school or community event Skilled: Sell products or services in a retail environment Advanced: Develop marketing campaigns for a small business Expert: Create and execute strategic marketing plans for large organizations | skills | Question Schema v1.1 | Child/Student/Self |
| How well do you understand and apply health and safety practices? Beginner: I could follow basic safety rules in the workplace Basic: Use personal protective equipment correctly Skilled: Conduct safety inspections and report hazards Advanced: Implement safety protocols and train others Expert: Develop comprehensive health and safety programs | skills | Question Schema v1.1 | Child/Student/Self |
| How proficient are you in conducting research to gather information? Beginner: Find basic information online Basic: Conduct research for a school project Skilled: Use multiple sources to compile detailed reports Advanced: Analyze research findings and present conclusions Expert: Conduct original research and publish findings | skills | Question Schema v1.1 | Child/Student/Self |
| How comfortable are you in interacting with others in a professional setting? Beginner: Greet and engage in small talk with colleagues Basic: Participate in group discussions Skilled: Build and maintain professional relationships Advanced: Negotiate and collaborate on complex tasks Expert: Manage relationships with clients, partners, and stakeholders | skills | Question Schema v1.1 | Child/Student/Self |
| How skilled are you in organizing and managing logistics? Beginner: Maybe I could organize a small event or gathering Basic: Coordinate the delivery of supplies for a project Skilled: Manage inventory and supply chains for a business Advanced: Oversee logistics for large-scale events or operations Expert: Develop and optimize complex logistical systems | skills | Question Schema v1.1 | Child/Student/Self |
| How comfortable are you with using various software tools? Beginner: Use basic word processing and spreadsheet tools Basic: Create presentations and simple databases Skilled: Utilize specialized software for specific tasks Advanced: Integrate multiple software tools for efficient workflows Expert: Develop custom software solutions or advanced integrations | skills | Question Schema v1.1 | Child/Student/Self |
| Can you remember a time when you learned something super fast? What was it, and why do you think you got the hang of it so quickly? | strengths | Question Schema v1.1 | Child/Student/Self |
| Think about a time when you faced a tough challenge. What kinds of skills did you use to get through it? | strengths | Question Schema v1.1 | Child/Student/Self |
| When you’re working on a group project or with friends, what role do you usually take on? Why do you think that is? | strengths | Question Schema v1.1 | Child/Student/Self |
| What are [child]'s strengths? | strengths | Question Schema v1.1 | Parent/Counselor |
| What do you believe [child] is capable of achieving? | strengths | Question Schema v1.1 | Parent/Counselor |
| Think about something fun you’ve worked on before, like a school project or a hobby. What made it so awesome for you? | strengths | Question Schema v1.1 | Child/Student/Self |
| Think about a time when you really understood what someone else was feeling. How did you respond to their emotions, and what happened after? | strengths | Question Schema v1.1 | Child/Student/Self |
| Think about a time when you noticed a problem that others didn’t see. How did you find it, and what did you do to fix it? | strengths | Question Schema v1.1 | Child/Student/Self |
| Think about a time when you took initiative to take the lead on a project. What made you want to step up? | strengths | Question Schema v1.1 | Child/Student/Self |
| Think about a past project or team that you were on that succeeded (in school, sports, or family for example). What was your role, and how did you help the team succeed? | strengths | Question Schema v1.1 | Child/Student/Self |
| Think about a time when you had to adapt quickly to a big change, like a new school or a different team. How did you handle it, and what happened in the end? | strengths | Question Schema v1.1 | Child/Student/Self |
| Think about a time when communication was super important to get something done. What was going on, and how did your way of talking or listening help? | strengths | Question Schema v1.1 | Child/Student/Self |
| Think about something you’re really proud of (school, extracurriculars). What challenges did you overcome to achieve this win? | strengths | Question Schema v1.1 | Child/Student/Self |
| Can you remember a time when you convinced others to see things your way, like during a group project or a debate? What did you do to persuade them? | strengths | Question Schema v1.1 | Child/Student/Self |
