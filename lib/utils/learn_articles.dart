import '../models/learn_article_model.dart';

/// Bundled Learn content. These articles are intentionally static so the
/// section remains available without a network connection or another
/// personal-data collection.
const List<LearnArticle> learnArticles = [
  LearnArticle(
    id: 'supports',
    title: 'What helps your mind on an ordinary day',
    category: LearnCategory.everydayLife,
    description:
        'Small, ordinary supports can make a difficult day more workable.',
    readTime: '3 min read',
    sections: [
      LearnArticleSection(
        heading: 'You do not need a perfect routine',
        paragraphs: [
          'When life feels heavy, advice can sound like another task. You do not need a perfect routine or a complete life reset before you deserve support. Often, the most useful supports are quiet and repeatable: a glass of water, a little rest, a familiar song, or one honest conversation.',
          'These things do not promise to fix everything. They can give your mind and body a little more room to respond to what is happening instead of carrying it alone.',
        ],
      ),
      LearnArticleSection(
        heading: 'Begin with what your body is asking for',
        paragraphs: [
          'Food, water, sleep, daylight, and gentle movement can affect how much capacity you have for the day. “Gentle” counts. Stretching for two minutes, standing by a window, or walking to the end of the street is still a way of caring for yourself.',
          'If your sleep, appetite, energy, or physical symptoms have changed for a while, that is worth mentioning to a qualified health professional. MindMate cannot tell you why a change is happening.',
        ],
      ),
      LearnArticleSection(
        heading: 'One safe person can be enough for today',
        paragraphs: [
          'A trusted person does not need to solve the problem. You might send a simple message such as, “Today is a lot. Can you check in with me later?” If talking feels too big, sitting near someone or sharing an ordinary activity can still reduce the feeling of being completely alone.',
          'Choose people who respect your boundaries. Support should not require you to share more than you want to share or stay in a situation that feels unsafe.',
        ],
      ),
      LearnArticleSection(
        heading: 'Give your mind somewhere to land',
        paragraphs: [
          'Constant input makes it difficult to notice what you need. A short pause from notifications, an unhurried shower, prayer or quiet reflection, drawing, music, or time outside can create a small gap between you and the next demand.',
          'You do not have to earn rest by finishing everything. Recovery is part of being able to keep going.',
        ],
      ),
      LearnArticleSection(
        heading: 'Pick the smallest thing you can actually do',
        paragraphs: [
          'Pick the option that feels possible, not the one that sounds most impressive. A small action that you can actually repeat is more useful than a long plan that leaves you feeling behind.',
        ],
      ),
    ],
    nextStepTitle: 'Try one small practice',
    nextStepDescription:
        'Open a breathing practice and give yourself a few quiet minutes. You can stop whenever you need to.',
    nextStepLabel: 'Try breathing',
    nextStepTool: LearnTool.breathing,
  ),
  LearnArticle(
    id: 'damages',
    title: 'The things that slowly wear you down',
    category: LearnCategory.everydayLife,
    description:
        'Notice the patterns that drain you, without turning that noticing into blame.',
    readTime: '3 min read',
    sections: [
      LearnArticleSection(
        heading: 'Notice what is costing you',
        paragraphs: [
          'Everyone has difficult seasons and unhelpful days. This is not a list for judging yourself or other people. It is an invitation to notice what keeps making life harder, especially when the pattern is easy to dismiss because it has become familiar.',
          'A hard day is not proof that you are failing. A repeated pattern is simply useful information about where you may need care or support.',
        ],
      ),
      LearnArticleSection(
        heading: 'When every day feels switched on',
        paragraphs: [
          'Deadlines, conflict, money worries, school, work, and family responsibilities can keep your mind in problem-solving mode. Without pauses, even ordinary tasks can start to feel urgent and exhausting.',
          'A short pause does not remove the situation. It can help you return to it with a little more choice. One breath, one glass of water, or writing down the next task can be a beginning.',
        ],
      ),
      LearnArticleSection(
        heading: 'The voice in your head matters',
        paragraphs: [
          'Pulling away can feel safer for a moment, especially when you are tired or embarrassed. Over time, being alone with every thought can make the thought feel more certain than it is.',
          'Notice the voice you use with yourself. “I made a mistake” leaves room for repair. “I am a mistake” closes that room. You can be honest about what happened without making yourself the enemy.',
        ],
      ),
      LearnArticleSection(
        heading: 'When avoiding starts shrinking your world',
        paragraphs: [
          'Putting something off can give quick relief. But if avoiding a message, place, person, or responsibility keeps shrinking your world, the short-term relief may be costing you more later.',
          'Try making the next step smaller: open the message without replying, write one sentence, or ask someone to sit with you while you begin. You are allowed to ask for help with the part that feels stuck.',
        ],
      ),
      LearnArticleSection(
        heading: 'Try one kind repair',
        paragraphs: [
          'You do not have to change every pattern today. Ask, “What would make the next hour five percent kinder?” Then choose one action that protects your time, your body, or your connection with a safe person.',
        ],
      ),
    ],
    nextStepTitle: 'Start with a check-in',
    nextStepDescription:
        'Name how this moment feels, then let MindMate suggest one manageable next step.',
    nextStepLabel: 'Check in now',
    nextStepTool: LearnTool.moodCheckIn,
  ),
  LearnArticle(
    id: 'substances',
    title: 'Substances and your brain: an honest conversation',
    category: LearnCategory.difficultMoments,
    description:
        'Clear information about cannabis, alcohol, codeine-based syrups, tramadol, and inhalants, without fear-mongering.',
    readTime: '5 min read',
    sections: [
      LearnArticleSection(
        heading: 'Let’s talk about this without shame',
        paragraphs: [
          'People use substances for many reasons: curiosity, pressure, pain, stress, celebration, or trying to get through the day. A non-judgmental conversation makes it easier to notice risk and ask for help. Shame usually makes honest conversations harder.',
          'The effect of a substance can vary with the person, amount, strength, timing, other substances, health, and surroundings. This is general information, not medical advice, and it is not a safe-use guide. If you are worried about your own use or someone else’s use, speak with a qualified health professional.',
        ],
      ),
      LearnArticleSection(
        heading: 'Cannabis: “natural” does not mean harmless',
        paragraphs: [
          'Myth: Because cannabis comes from a plant, it cannot cause problems. Reality: cannabis can affect attention, memory, reaction time, coordination, and mood while it is active. Some people also find that it makes worry, panic, or confusing thoughts harder to manage.',
          'If cannabis is becoming the main way you sleep, relax, eat, socialise, or avoid a feeling, that pattern is worth talking about. You do not need to wait for a crisis before asking for support.',
        ],
      ),
      LearnArticleSection(
        heading: 'The relief can come with a cost',
        paragraphs: [
          'Myth: If alcohol takes the edge off, it is helping the problem. Reality: it can slow reactions and judgment, affect sleep, and leave some people feeling more low or anxious afterwards. It can also make a difficult situation less predictable.',
          'Needing alcohol to feel able to sleep, socialise, or cope is a reason to pause and get support, not a reason to feel ashamed. Mixing alcohol with medicines or other substances can be especially risky.',
        ],
      ),
      LearnArticleSection(
        heading: 'Codeine-based syrups: medicine is not automatically safe',
        paragraphs: [
          'Myth: A cough syrup is mild because it is sold as medicine. Reality: products containing codeine can cause drowsiness and dependence, and can be dangerous when taken in the wrong amount, shared, or combined with other substances.',
          'Use medicines only as directed by a qualified health professional or the product instructions, and never share someone else’s prescription. If you are concerned about a medicine, ask a pharmacist or doctor rather than guessing.',
        ],
      ),
      LearnArticleSection(
        heading: 'Tramadol: a prescription is not a personal safety guarantee',
        paragraphs: [
          'Myth: If tramadol was prescribed for someone, it is safe for anyone to take. Reality: tramadol can cause serious problems when it is used by the wrong person, taken in the wrong way, or combined with other medicines or substances. It can also become difficult to stop using.',
          'Do not use another person’s pain medicine. A doctor or pharmacist can give advice about a medicine you were prescribed and about concerns such as side effects or dependence.',
        ],
      ),
      LearnArticleSection(
        heading: 'Inhalants: “just fumes” can become an emergency',
        paragraphs: [
          'Myth: Household or industrial fumes are only a brief way to feel different. Reality: inhalants can affect the brain and heart quickly, and the effects are unpredictable. A person can become confused, lose consciousness, or become seriously unwell.',
          'If someone has collapsed, is having trouble breathing, is having a seizure, or cannot be woken after using a substance, treat it as an emergency. Move to safety if you can do so without exposing yourself, and use local emergency help immediately.',
        ],
      ),
      LearnArticleSection(
        heading: 'A worried conversation is still worth having',
        paragraphs: [
          'You can start with, “I have noticed you seem different, and I care about you. Do you want to talk?” Listen without trying to win an argument. If there is immediate danger, involve emergency help or a trusted adult instead of keeping it secret.',
        ],
      ),
    ],
    nextStepTitle: 'Find support without waiting for a crisis',
    nextStepDescription:
        'MindMate’s Emergency Support screen brings together local options and clear next steps. It does not replace a health professional or emergency service.',
    nextStepLabel: 'Open support options',
    nextStepTool: LearnTool.emergencySupport,
  ),
  LearnArticle(
    id: 'coping',
    title: 'When your usual coping stops helping',
    category: LearnCategory.difficultMoments,
    description:
        'A few honest questions can help you notice when relief is starting to cost you.',
    readTime: '4 min read',
    sections: [
      LearnArticleSection(
        heading: 'Coping is not supposed to trap you',
        paragraphs: [
          'Coping can be positive, ordinary, and creative. Resting, praying, talking, moving, making music, distracting yourself for a while, or asking for help can all help you make it through a hard moment.',
          'A strategy can help today and still become a problem when it is the only strategy left, causes harm, or makes your world smaller. This is about noticing a pattern, not diagnosing yourself.',
        ],
      ),
      LearnArticleSection(
        heading: 'Look past the quick relief',
        paragraphs: [
          'After I use this coping strategy, do I feel more able to face the next step, or more stuck? Is it affecting my sleep, health, money, relationships, school, or work? Am I hiding it because I am worried about how it looks?',
          'Do I need more of it, or need to do it for longer, to get the same relief? What happens when I try not to do it? These questions are not a test and there is no score to pass.',
        ],
      ),
      LearnArticleSection(
        heading: 'Something can help and still hurt',
        paragraphs: [
          'If a behaviour, substance, or routine gives you a break from pain, it makes sense that your mind reaches for it again. That does not make you weak. It may mean the pain needs more support than one private strategy can provide.',
          'Try to look at the whole picture with kindness. You can keep the parts that help while asking for a safer or more sustainable option for the parts that are hurting you.',
        ],
      ),
      LearnArticleSection(
        heading: 'You can talk before it becomes a crisis',
        paragraphs: [
          'A trusted person, counsellor, doctor, psychologist, or other qualified professional can help you think through what is happening. You can begin with one sentence: “Something I use to cope is starting to worry me, and I do not know what to do next.”',
          'If you might hurt yourself or someone else, or you cannot stay safe right now, skip the self-reflection and use immediate emergency or crisis support.',
        ],
      ),
    ],
    nextStepTitle: 'Put the thought somewhere safe',
    nextStepDescription:
        'Use a private journal entry to name the pattern, what it costs, and one person or service you could contact.',
    nextStepLabel: 'Open your journal',
    nextStepTool: LearnTool.journal,
  ),
  LearnArticle(
    id: 'help-nigeria',
    title: 'Finding support in Nigeria',
    category: LearnCategory.gettingHelp,
    description:
        'Support is not a sign of failure. Here is how to think about the next human step.',
    readTime: '4 min read',
    sections: [
      LearnArticleSection(
        heading: 'You can start with “I need help”',
        paragraphs: [
          'Asking for help can feel exposing, especially when people around you have treated mental health as something to hide. You are allowed to ask for support before you have the right words, a formal label, or a crisis.',
          'You might begin with a trusted friend, family member, teacher, faith leader, school counsellor, community health worker, doctor, or qualified mental-health professional. Choose someone who will listen and respect your safety.',
        ],
      ),
      LearnArticleSection(
        heading: 'When you have time to plan',
        paragraphs: [
          'A primary health centre, general hospital, teaching hospital, or qualified mental-health professional may be a starting point. The right service depends on your situation and location. A doctor or other qualified professional can help you decide what care is appropriate.',
          'MindMate’s professional directory is a request-based prototype. Its competition listings are clearly labelled demo data, not an endorsement or proof that a provider is available. A request is not a confirmed appointment.',
        ],
      ),
      LearnArticleSection(
        heading: 'When help cannot wait',
        paragraphs: [
          'If someone is in immediate danger, may act on thoughts of suicide or serious self-harm, has a serious reaction to a substance, cannot be woken, or needs urgent physical care, use emergency help now. Do not rely on an app chat to manage an emergency.',
          'The Emergency Support screen includes Nigeria-wide and state options, the 112 fallback, and international choices when relevant. Numbers and services can change, so check the current options shown in the app and use the nearest emergency department when needed.',
        ],
      ),
      LearnArticleSection(
        heading: 'Take a few words with you',
        paragraphs: [
          'You can write down what changed, how long it has been happening, what makes it better or worse, and what you are afraid might happen. You do not have to defend your feelings or prove that they are serious enough.',
          'If the first person does not respond well, that is information about that conversation, not a verdict on whether you deserve help. Try another trusted person or service.',
        ],
      ),
    ],
    nextStepTitle: 'See support options for your situation',
    nextStepDescription:
        'Open the in-app support page for location choices and user-triggered call or message actions. MindMate never contacts anyone silently.',
    nextStepLabel: 'Open Emergency Support',
    nextStepTool: LearnTool.emergencySupport,
  ),
  LearnArticle(
    id: 'friend',
    title: 'When a friend is not okay',
    category: LearnCategory.loveAndPeople,
    description:
        'You can listen, take warning signs seriously, and bring in more support without carrying this alone.',
    readTime: '4 min read',
    sections: [
      LearnArticleSection(
        heading: 'Be the person who makes it easier to talk',
        paragraphs: [
          'Choose a private moment and speak about what you have noticed: “You have seemed quieter lately, and I care about you. How are you really doing?” Give them time to answer. You do not need to fill every silence.',
          'Listen for understanding rather than immediately offering a solution. You can say, “That sounds really hard,” or “Thank you for telling me.” Taking someone seriously does not mean agreeing with every conclusion they have made.',
        ],
      ),
      LearnArticleSection(
        heading: 'Keep your words simple and steady',
        paragraphs: [
          'Helpful words are specific and steady: “I am here with you,” “You do not have to handle this alone,” and “Can we find a trusted adult or professional together?” Ask what kind of help would feel possible right now.',
          'Avoid “cheer up,” “other people have it worse,” “just forget about it,” or accusations that they are seeking attention. Avoid promising to keep a serious safety concern secret.',
        ],
      ),
      LearnArticleSection(
        heading: 'Know when to bring someone else in',
        paragraphs: [
          'If your friend says they may hurt themselves or someone else, has taken a dangerous substance, cannot stay safe, or is in immediate danger, involve a trusted adult, qualified professional, or emergency service. If you are both young, tell a responsible adult even if your friend asks you not to.',
          'Stay with them or help them get to a safer person and place when you can do so safely. Do not put yourself in danger or try to be the only person responsible for keeping them safe.',
        ],
      ),
      LearnArticleSection(
        heading: 'Care for them without carrying it alone',
        paragraphs: [
          'You can care deeply and still set limits. You are not a therapist or an emergency service. Encourage your friend to build more than one source of support, and talk to a trusted adult or professional yourself if the situation is affecting you.',
          'A small follow-up message can matter: “I am thinking of you. Would you like company, a call, or help finding support today?”',
        ],
      ),
    ],
    nextStepTitle: 'Keep human support close',
    nextStepDescription:
        'Open Emergency Support to review options together. If there is immediate danger, use emergency help rather than waiting for an app response.',
    nextStepLabel: 'Open support options',
    nextStepTool: LearnTool.emergencySupport,
  ),
      LearnArticle(
        id: 'day-starts-badly',
        title: 'When the day starts badly',
        description:
            'A rough morning does not have to decide what the rest of the day becomes.',
        readTime: '3 min read',
        category: LearnCategory.everydayLife,
        sections: [
          LearnArticleSection(
            heading: 'Do not make the morning a verdict',
            paragraphs: [
              'You can wake up tired, late, upset, or already behind. That does not mean the whole day is ruined, and it does not say anything final about you.',
              'Before you judge the day, name what actually happened. A bad night, a difficult message, or an argument is real, but it is still one part of the day.',
            ],
          ),
          LearnArticleSection(
            heading: 'Make the next hour smaller',
            paragraphs: [
              'Start with the basics that are available: drink some water, wash your face, eat something if you can, step outside, or put one task in front of you. You do not need to feel motivated before starting.',
              'If you are late or have missed something, send one honest message instead of spending the whole morning hiding from it. Repair is usually easier when it starts early.',
            ],
          ),
          LearnArticleSection(
            heading: 'Leave room for a reset',
            paragraphs: [
              'The goal is not to turn a difficult morning into a perfect day. The goal is to give yourself another chance at the next moment.',
            ],
          ),
        ],
        nextStepTitle: 'Choose one reset',
        nextStepDescription:
            'Check in with how you feel right now, then choose one small action for the next part of your day.',
        nextStepLabel: 'Check in now',
        nextStepTool: LearnTool.moodCheckIn,
      ),
      LearnArticle(
        id: 'school-work-overwhelming',
        title: 'When school, exams, or work feel overwhelming',
        description:
            'Pressure gets easier to approach when you stop asking yourself to solve everything at once.',
        readTime: '3 min read',
        category: LearnCategory.everydayLife,
        sections: [
          LearnArticleSection(
            heading: 'Overwhelm is a signal, not a character flaw',
            paragraphs: [
              'A long list can make every task feel equally urgent. Your mind may start avoiding the work because it cannot see a safe place to begin. That does not make you lazy or incapable.',
              'Write down what is actually due, what matters most, and what can wait. Seeing the list outside your head can lower some of the pressure.',
            ],
          ),
          LearnArticleSection(
            heading: 'Pick the first visible step',
            paragraphs: [
              'Do not start with “finish the project.” Start with “open the document,” “read the question,” or “write three rough lines.” A small start is still progress, even when the final task is large.',
              'Try a short period of focused work followed by a real pause. Tell someone if the workload is beyond what you can reasonably carry, especially if deadlines or expectations are affecting your health.',
            ],
          ),
          LearnArticleSection(
            heading: 'You are more than your output',
            paragraphs: [
              'A result, grade, or missed deadline can matter without becoming your identity. Ask for clarification, extra support, or a different plan when you need it.',
            ],
          ),
        ],
        nextStepTitle: 'Put the pressure somewhere',
        nextStepDescription:
            'Write down what feels most urgent and one small step you could take before the day ends.',
        nextStepLabel: 'Open your journal',
        nextStepTool: LearnTool.journal,
      ),
      LearnArticle(
        id: 'social-media-behind',
        title: 'When social media makes you feel behind',
        description:
            'A feed shows moments, not the full lives of the people in it.',
        readTime: '3 min read',
        category: LearnCategory.everydayLife,
        sections: [
          LearnArticleSection(
            heading: 'The comparison is missing information',
            paragraphs: [
              'You see someone’s announcement, outfit, relationship, trip, or achievement. You usually do not see their uncertainty, arguments, debt, boredom, or ordinary Tuesday. Comparing your whole life with a selected moment will rarely feel fair.',
              'Feeling jealous or discouraged does not make you a bad person. It is a sign to notice what the feed is bringing up for you.',
            ],
          ),
          LearnArticleSection(
            heading: 'Take back a little attention',
            paragraphs: [
              'Try leaving the app for ten minutes before deciding what you believe about yourself. Put the phone in another room, mute accounts that reliably make you feel worse, or choose a time when you will stop scrolling.',
              'Replace some of the time with something that gives you information about your own life: a walk, music, a conversation, food, study, or rest.',
            ],
          ),
          LearnArticleSection(
            heading: 'Your pace is still a pace',
            paragraphs: [
              'You are allowed to want more for yourself without treating your current life as worthless. Progress that nobody posts still counts.',
            ],
          ),
        ],
        nextStepTitle: 'Notice what the feed stirred up',
        nextStepDescription:
            'Use a private entry to name the comparison, the feeling underneath it, and one thing that belongs to your own life.',
        nextStepLabel: 'Write it down',
        nextStepTool: LearnTool.journal,
      ),
      LearnArticle(
        id: 'unreturned-feelings',
        title: 'When you like someone who does not feel the same way',
        description:
            'Rejection can hurt without becoming a statement about your worth.',
        readTime: '3 min read',
        category: LearnCategory.loveAndPeople,
        sections: [
          LearnArticleSection(
            heading: 'It is okay for this to hurt',
            paragraphs: [
              'You can understand that someone is not interested and still feel disappointed, embarrassed, or sad. Respecting their answer does not require you to switch off your feelings immediately.',
              'Their choice may be about what they want, what they can offer, or simply what they feel. It is not a measurement of your value.',
            ],
          ),
          LearnArticleSection(
            heading: 'Give yourself some distance',
            paragraphs: [
              'If checking their messages or social media keeps reopening the hurt, create a little space. You do not have to punish them or yourself. You are allowed to mute, step back, and spend time with people who help you feel like yourself.',
              'Try not to bargain with a clear no or turn kindness into evidence of a hidden promise. A respectful relationship needs interest and consent from both people.',
            ],
          ),
          LearnArticleSection(
            heading: 'Let the feeling move',
            paragraphs: [
              'Talk to someone safe, write what you wish you could say without sending it, or return to an activity that reminds you who you are outside this one person.',
            ],
          ),
        ],
        nextStepTitle: 'Give the feeling somewhere to go',
        nextStepDescription:
            'Write honestly about what you hoped for and what you need from yourself today. You do not have to send the entry.',
        nextStepLabel: 'Open your journal',
        nextStepTool: LearnTool.journal,
      ),
      LearnArticle(
        id: 'breakup-week',
        title: 'When a breakup changes your whole week',
        description:
            'There is no correct timetable for missing someone, even when ending things was necessary.',
        readTime: '3 min read',
        category: LearnCategory.loveAndPeople,
        sections: [
          LearnArticleSection(
            heading: 'You are grieving a real change',
            paragraphs: [
              'A breakup can change your routines, plans, friendships, and sense of the future. It can hurt even when you know the relationship was not working or the decision was right.',
              'Feelings may arrive in waves. One okay afternoon does not mean you are finished, and one painful evening does not mean you are back at the beginning.',
            ],
          ),
          LearnArticleSection(
            heading: 'Protect the tender parts',
            paragraphs: [
              'Choose what contact feels safe and useful. Repeated checking, late-night arguments, or using a new person to avoid every feeling may keep the wound open. A little distance can be care, not cruelty.',
              'Keep basic routines where you can. Eat, rest, attend what you need to attend, and tell one trusted person when a day feels especially hard.',
            ],
          ),
          LearnArticleSection(
            heading: 'Do not rush to rewrite the story',
            paragraphs: [
              'You can remember the good parts and still accept that the relationship ended. You can miss someone and decide not to return. Both things can be true.',
            ],
          ),
        ],
        nextStepTitle: 'Take one quiet minute for yourself',
        nextStepDescription:
            'A short breathing practice can help you get through the next wave without making a decision in the middle of it.',
        nextStepLabel: 'Try breathing',
        nextStepTool: LearnTool.breathing,
      ),
      LearnArticle(
        id: 'love-pressure',
        title: 'When love starts feeling like pressure',
        description:
            'Care should leave room for your choices, your boundaries, and your safety.',
        readTime: '4 min read',
        category: LearnCategory.loveAndPeople,
        sections: [
          LearnArticleSection(
            heading: 'Pressure is not proof of love',
            paragraphs: [
              'Someone may say that you would do something if you really loved them. They may threaten to leave, demand private information, or make you feel guilty for having a boundary. That is pressure, not a requirement you have to meet.',
              'You are allowed to take time, change your mind, and say no to sex, private photos, passwords, money, or any other request. Consent has to be freely given and can be withdrawn.',
            ],
          ),
          LearnArticleSection(
            heading: 'Notice how your no is treated',
            paragraphs: [
              'A safe person may feel disappointed, but they do not punish, threaten, isolate, or humiliate you for having a choice. Repeated monitoring, intimidation, or control deserves to be taken seriously.',
              'Talk to someone you trust before confronting a person who may become threatening. Keep your safety and access to support in mind.',
            ],
          ),
          LearnArticleSection(
            heading: 'You do not owe a performance',
            paragraphs: [
              'A relationship should not require you to abandon your safety or prove your worth over and over. If you feel afraid, seek human support rather than trying to manage the pressure alone.',
            ],
          ),
        ],
        nextStepTitle: 'Put your boundary into words',
        nextStepDescription:
            'A private note can help you name what happened, what you want, and which trusted person could support you.',
        nextStepLabel: 'Open your journal',
        nextStepTool: LearnTool.journal,
      ),
      LearnArticle(
        id: 'mixed-signals-boundaries',
        title: 'When someone gives you mixed signals or crosses your boundaries',
        description:
            'Confusion is worth noticing, especially when your clear limits are not being respected.',
        readTime: '4 min read',
        category: LearnCategory.loveAndPeople,
        sections: [
          LearnArticleSection(
            heading: 'Look at the pattern, not only the apology',
            paragraphs: [
              'One awkward conversation can be repaired. A repeated pattern of intense attention, withdrawal, guilt, and apology can leave you constantly trying to earn stability. You are allowed to pay attention to how the relationship makes you feel.',
              'If you say no or ask for space, the important question is whether the person respects it. Kind words do not cancel repeated pressure or control.',
            ],
          ),
          LearnArticleSection(
            heading: 'Make the boundary clear to yourself first',
            paragraphs: [
              'Write down what you are and are not comfortable with. You do not need a courtroom argument before your boundary becomes real. “I do not want that” is enough.',
              'If saying it directly may put you at risk, do not prioritise a perfect explanation. Speak to a trusted person and make a safer plan for distance or support.',
            ],
          ),
          LearnArticleSection(
            heading: 'Confusion should not cost your safety',
            paragraphs: [
              'You can care about someone and still step back. If there are threats, stalking, violence, or immediate danger, involve a trusted adult or emergency support rather than handling it privately.',
            ],
          ),
        ],
        nextStepTitle: 'Write down what you noticed',
        nextStepDescription:
            'A private record can help you see the pattern clearly and prepare to talk to someone you trust.',
        nextStepLabel: 'Open your journal',
        nextStepTool: LearnTool.journal,
      ),
      LearnArticle(
        id: 'panic-next-step',
        title: 'When you feel panicked and do not know what to do next',
        description:
            'You do not have to solve the whole situation while your body is sounding an alarm.',
        readTime: '3 min read',
        category: LearnCategory.difficultMoments,
        sections: [
          LearnArticleSection(
            heading: 'Come back to the immediate moment',
            paragraphs: [
              'Panic can make everything feel urgent. If you can, put both feet on the floor and notice a few things you can see, hear, and feel. Let your exhale be a little slower than your inhale without forcing a deep breath.',
              'Move away from traffic, heights, conflict, or anything else that could make the moment less safe. Ask someone nearby to stay with you if that would help.',
            ],
          ),
          LearnArticleSection(
            heading: 'Use simple words',
            paragraphs: [
              'You can say, “I am overwhelmed. Please stay with me for a minute,” or “I need somewhere quieter.” You do not have to explain the entire history before asking for immediate support.',
              'If you have new or severe physical symptoms, cannot stay safe, or think this may be a medical emergency, seek urgent human help instead of assuming it is only panic.',
            ],
          ),
          LearnArticleSection(
            heading: 'Let the wave pass before deciding',
            paragraphs: [
              'When the intensity lowers, consider what triggered the moment and what support you may need next. A repeated or disruptive experience is worth discussing with a qualified professional.',
            ],
          ),
        ],
        nextStepTitle: 'Breathe through the next minute',
        nextStepDescription:
            'Try a guided breathing pattern at your own pace. Stop if it feels uncomfortable and choose human support when you need it.',
        nextStepLabel: 'Start a breathing practice',
        nextStepTool: LearnTool.breathing,
      ),
      LearnArticle(
        id: 'friend-cannot-stay-safe',
        title: 'When a friend says they cannot stay safe',
        description:
            'Take the words seriously, bring in another person, and do not carry the emergency alone.',
        readTime: '3 min read',
        category: LearnCategory.gettingHelp,
        sections: [
          LearnArticleSection(
            heading: 'Do not promise to keep it secret',
            paragraphs: [
              'You can respond calmly: “I am glad you told me. I care about you, and I am going to help bring in someone who can keep you safe.” A serious safety concern is more important than protecting a promise made in fear.',
              'Ask whether they are in immediate danger, have already done something to hurt themselves, or have access to something they might use. You do not need to investigate or make a judgement about their answer.',
            ],
          ),
          LearnArticleSection(
            heading: 'Bring in a trusted adult or professional now',
            paragraphs: [
              'Tell a responsible adult, qualified professional, or emergency service. If you are both young, involve an adult even if your friend is angry with you. Stay with your friend or help them reach a safer person when you can do so safely.',
              'Do not leave an immediate danger situation to an app chat. MindMate can help you find support options, but it cannot provide emergency intervention.',
            ],
          ),
          LearnArticleSection(
            heading: 'Care without becoming the only support',
            paragraphs: [
              'You can be an important friend without being the person who manages every risk. Keep yourself safe, ask for help, and follow up when the immediate moment has passed.',
            ],
          ),
        ],
        nextStepTitle: 'Open human-support options',
        nextStepDescription:
            'Use Emergency Support together. If your friend is in immediate danger, contact local emergency help now.',
        nextStepLabel: 'Open Emergency Support',
        nextStepTool: LearnTool.emergencySupport,
      ),
      LearnArticle(
        id: 'substance-emergency',
        title: 'When someone has taken too much of a substance',
        description:
            'If someone is hard to wake, struggling to breathe, or seriously unwell, treat it as an emergency.',
        readTime: '3 min read',
        category: LearnCategory.gettingHelp,
        sections: [
          LearnArticleSection(
            heading: 'Do not wait for certainty',
            paragraphs: [
              'You may not know what was taken, how much, or when. You do not need that information before asking for emergency help. Trouble breathing, collapse, a seizure, severe confusion, or being unable to wake someone are urgent warning signs.',
              'Move away from fumes, traffic, violence, or other danger if you can do so safely. Do not expose yourself or try to manage an unknown substance alone.',
            ],
          ),
          LearnArticleSection(
            heading: 'Tell responders what you know',
            paragraphs: [
              'Keep any packaging or information available for responders if it is safe to do so. Be honest about what you saw. The goal is care, not punishment.',
              'Do not force food or drink, make the person exercise, or wait for them to sleep it off when they are seriously unwell. Follow the instructions of emergency professionals.',
            ],
          ),
          LearnArticleSection(
            heading: 'Protect the person and yourself',
            paragraphs: [
              'Stay nearby and keep the area as calm as possible while human help is coming. If the situation is not immediately dangerous but substance use is worrying you, seek qualified support after the urgent moment has passed.',
            ],
          ),
        ],
        nextStepTitle: 'Use immediate human support',
        nextStepDescription:
            'Open the emergency options now. MindMate is not a substitute for an ambulance, hospital, or emergency service.',
        nextStepLabel: 'Open Emergency Support',
        nextStepTool: LearnTool.emergencySupport,
      ),
];

const List<LearnArticle> learnExploreArticles = [
  LearnArticle(
    id: 'mind-wont-switch-off',
    title: 'When your mind will not switch off',
    description:
        'A busy mind may need a softer landing, not another demand to relax perfectly.',
    readTime: '3 min read',
    category: LearnCategory.everydayLife,
    sections: [
      LearnArticleSection(
        heading: 'Name the loop',
        paragraphs: [
          'Notice whether you are planning, replaying, worrying, or trying to solve something that cannot be solved tonight. Naming the loop can create a little distance from it.',
        ],
      ),
      LearnArticleSection(
        heading: 'Give the thought a place to wait',
        paragraphs: [
          'Write down the next useful action and when you will return to it. Then choose a quiet activity that does not ask you to perform or decide.',
        ],
      ),
    ],
    nextStepTitle: 'Slow the room down',
    nextStepDescription:
        'Try a short guided breathing practice and let the next decision wait for a moment.',
    nextStepLabel: 'Try breathing',
    nextStepTool: LearnTool.breathing,
  ),
  LearnArticle(
    id: 'procrastination',
    title: 'When you keep procrastinating',
    description:
        'Avoidance is often protecting you from a feeling, not proving that you do not care.',
    readTime: '3 min read',
    category: LearnCategory.everydayLife,
    sections: [
      LearnArticleSection(
        heading: 'Ask what the task brings up',
        paragraphs: [
          'The task may feel boring, confusing, impossible, or connected to fear of getting it wrong. “Why am I lazy?” usually gives less useful information than “What feels difficult about beginning?”',
        ],
      ),
      LearnArticleSection(
        heading: 'Make beginning almost too small to avoid',
        paragraphs: [
          'Open the page, put the materials on the table, or work for five minutes. A beginning does not commit you to finishing everything at once.',
        ],
      ),
    ],
    nextStepTitle: 'Name the stuck point',
    nextStepDescription:
        'Write one sentence about what you are avoiding and the smallest start you can make.',
    nextStepLabel: 'Open your journal',
    nextStepTool: LearnTool.journal,
  ),
  LearnArticle(
    id: 'cannot-concentrate',
    title: 'When you cannot concentrate',
    description:
        'Focus is harder when your body is tired, your environment is noisy, or your mind is carrying too much.',
    readTime: '3 min read',
    category: LearnCategory.everydayLife,
    sections: [
      LearnArticleSection(
        heading: 'Check the conditions first',
        paragraphs: [
          'Have you eaten, rested, had water, or had a chance to move? Can you reduce notifications or work somewhere a little quieter? Small changes are not silly when attention is already stretched.',
        ],
      ),
      LearnArticleSection(
        heading: 'Choose one lane',
        paragraphs: [
          'Put one task in front of you and decide what “enough for now” looks like. If concentration problems keep disrupting your life, talk to a qualified professional instead of diagnosing yourself from a checklist.',
        ],
      ),
    ],
    nextStepTitle: 'Make one small lane',
    nextStepDescription:
        'Check in with your current state and choose one manageable action instead of trying to fix your whole routine.',
    nextStepLabel: 'Check in now',
    nextStepTool: LearnTool.moodCheckIn,
  ),
  LearnArticle(
    id: 'feeling-lonely',
    title: 'When you feel lonely in a crowded room',
    description:
        'Being around people is not the same as feeling known, and you are not strange for noticing the difference.',
    readTime: '3 min read',
    category: LearnCategory.loveAndPeople,
    sections: [
      LearnArticleSection(
        heading: 'Start with one honest connection',
        paragraphs: [
          'You do not need to become social everywhere. Send one message, sit near a safe person, or suggest a simple shared activity. “I have been feeling alone lately” may be enough of an opening.',
        ],
      ),
      LearnArticleSection(
        heading: 'Do not turn loneliness into a verdict',
        paragraphs: [
          'Feeling disconnected today does not mean you are unlovable or destined to stay alone. It is a need for connection, not a final description of who you are.',
        ],
      ),
    ],
    nextStepTitle: 'Put the feeling into words',
    nextStepDescription:
        'Write what kind of connection you are missing and who might be safe to contact.',
    nextStepLabel: 'Open your journal',
    nextStepTool: LearnTool.journal,
  ),
  LearnArticle(
    id: 'need-to-say-no',
    title: 'When you need to say no',
    description:
        'A boundary can be kind, firm, and brief. You do not have to build a perfect case for it.',
    readTime: '3 min read',
    category: LearnCategory.loveAndPeople,
    sections: [
      LearnArticleSection(
        heading: 'Your capacity is part of the answer',
        paragraphs: [
          'You may say no because you are tired, uncomfortable, busy, or simply do not want to. A request is not an order, and another person’s disappointment does not automatically mean you did something wrong.',
        ],
      ),
      LearnArticleSection(
        heading: 'Keep the sentence simple',
        paragraphs: [
          'Try “I cannot do that,” “I need more time,” or “I am not comfortable with this.” You can repeat yourself without entering a long debate. If the person becomes threatening, prioritise safety and bring in another person.',
        ],
      ),
    ],
    nextStepTitle: 'Practise your boundary privately',
    nextStepDescription:
        'Write the sentence you wish you could say and the support you would want if it is not respected.',
    nextStepLabel: 'Open your journal',
    nextStepTool: LearnTool.journal,
  ),
  LearnArticle(
    id: 'jealousy',
    title: 'When jealousy starts taking over',
    description:
        'Jealousy can point to fear or insecurity, but it does not give you permission to control someone.',
    readTime: '3 min read',
    category: LearnCategory.loveAndPeople,
    sections: [
      LearnArticleSection(
        heading: 'Separate the feeling from the action',
        paragraphs: [
          'You may feel afraid of losing someone without checking their phone, tracking their location, or demanding constant proof. Feelings deserve attention; controlling behaviour can damage trust and safety.',
        ],
      ),
      LearnArticleSection(
        heading: 'Ask what you actually need',
        paragraphs: [
          'Do you need reassurance, a clearer agreement, more honest communication, or support with an old fear? Ask directly instead of building a case from guesses.',
        ],
      ),
    ],
    nextStepTitle: 'Slow down before reacting',
    nextStepDescription:
        'Write the fear underneath the jealousy and one respectful request you could make.',
    nextStepLabel: 'Open your journal',
    nextStepTool: LearnTool.journal,
  ),
  LearnArticle(
    id: 'family-does-not-understand',
    title: 'When your family does not understand how you feel',
    description:
        'You can want understanding without having to win one difficult conversation.',
    readTime: '3 min read',
    category: LearnCategory.loveAndPeople,
    sections: [
      LearnArticleSection(
        heading: 'Choose what is safe to share',
        paragraphs: [
          'Not every person or moment is safe for your full story. You can start with one feeling, one request, or a trusted person outside your home who can help you think through the next step.',
        ],
      ),
      LearnArticleSection(
        heading: 'Explain the help you want',
        paragraphs: [
          'Try “I do not need a lecture right now; I need you to listen,” or “Please help me find a qualified person to talk to.” If home is unsafe, do not confront the person alone. Reach out to a trusted adult or appropriate support service.',
        ],
      ),
    ],
    nextStepTitle: 'Prepare your first sentence',
    nextStepDescription:
        'Write down what is happening, what you need, and the safest person you could tell.',
    nextStepLabel: 'Open your journal',
    nextStepTool: LearnTool.journal,
  ),
  LearnArticle(
    id: 'help-does-not-answer',
    title: 'When the first help option does not answer',
    description:
        'One unanswered call does not mean there is nowhere else to turn.',
    readTime: '3 min read',
    category: LearnCategory.gettingHelp,
    sections: [
      LearnArticleSection(
        heading: 'Keep moving toward a human',
        paragraphs: [
          'Try another available emergency option, a nearby hospital emergency department, a trusted adult, or a person who can stay with you while you make the next call. If you are in immediate danger, do not wait alone for one number to answer.',
        ],
      ),
      LearnArticleSection(
        heading: 'Use the options in front of you',
        paragraphs: [
          'MindMate’s Emergency Support screen includes Nigeria-wide and state choices, the 112 fallback, and international options when relevant. Services and numbers can change, so use the current options shown in the app and seek nearby human help.',
        ],
      ),
    ],
    nextStepTitle: 'Open the backup options',
    nextStepDescription:
        'Review the available human-support routes. If there is immediate danger, use local emergency help now.',
    nextStepLabel: 'Open Emergency Support',
    nextStepTool: LearnTool.emergencySupport,
  ),
];
