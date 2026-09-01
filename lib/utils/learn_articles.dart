import '../models/learn_article_model.dart';

/// Bundled Learn content. These articles are intentionally static so the
/// section remains available without a network connection or another
/// personal-data collection.
const List<LearnArticle> learnArticles = [
  LearnArticle(
    id: 'supports',
    title: 'Things that quietly support your mind',
    description:
        'Small, ordinary supports can make a difficult day more workable.',
    readTime: '3 min read',
    sections: [
      LearnArticleSection(
        heading: 'Support does not have to be impressive',
        paragraphs: [
          'When life feels heavy, advice can sound like another task. You do not need a perfect routine or a complete life reset before you deserve support. Often, the most useful supports are quiet and repeatable: a glass of water, a little rest, a familiar song, or one honest conversation.',
          'These things do not promise to fix everything. They can give your mind and body a little more room to respond to what is happening instead of carrying it alone.',
        ],
      ),
      LearnArticleSection(
        heading: 'Start with the body you have today',
        paragraphs: [
          'Food, water, sleep, daylight, and gentle movement can affect how much capacity you have for the day. “Gentle” counts. Stretching for two minutes, standing by a window, or walking to the end of the street is still a way of caring for yourself.',
          'If your sleep, appetite, energy, or physical symptoms have changed for a while, that is worth mentioning to a qualified health professional. MindMate cannot tell you why a change is happening.',
        ],
      ),
      LearnArticleSection(
        heading: 'Keep one thread of connection',
        paragraphs: [
          'A trusted person does not need to solve the problem. You might send a simple message such as, “Today is a lot. Can you check in with me later?” If talking feels too big, sitting near someone or sharing an ordinary activity can still reduce the feeling of being completely alone.',
          'Choose people who respect your boundaries. Support should not require you to share more than you want to share or stay in a situation that feels unsafe.',
        ],
      ),
      LearnArticleSection(
        heading: 'Make room for recovery',
        paragraphs: [
          'Constant input makes it difficult to notice what you need. A short pause from notifications, an unhurried shower, prayer or quiet reflection, drawing, music, or time outside can create a small gap between you and the next demand.',
          'You do not have to earn rest by finishing everything. Recovery is part of being able to keep going.',
        ],
      ),
      LearnArticleSection(
        heading: 'Choose one small support',
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
    title: 'Things that quietly damage your mind',
    description:
        'Notice the patterns that drain you, without turning that noticing into blame.',
    readTime: '3 min read',
    sections: [
      LearnArticleSection(
        heading: 'This is about patterns, not blame',
        paragraphs: [
          'Everyone has difficult seasons and unhelpful days. This is not a list for judging yourself or other people. It is an invitation to notice what keeps making life harder, especially when the pattern is easy to dismiss because it has become familiar.',
          'A hard day is not proof that you are failing. A repeated pattern is simply useful information about where you may need care or support.',
        ],
      ),
      LearnArticleSection(
        heading: 'Running on pressure all the time',
        paragraphs: [
          'Deadlines, conflict, money worries, school, work, and family responsibilities can keep your mind in problem-solving mode. Without pauses, even ordinary tasks can start to feel urgent and exhausting.',
          'A short pause does not remove the situation. It can help you return to it with a little more choice. One breath, one glass of water, or writing down the next task can be a beginning.',
        ],
      ),
      LearnArticleSection(
        heading: 'Isolation and harsh self-talk',
        paragraphs: [
          'Pulling away can feel safer for a moment, especially when you are tired or embarrassed. Over time, being alone with every thought can make the thought feel more certain than it is.',
          'Notice the voice you use with yourself. “I made a mistake” leaves room for repair. “I am a mistake” closes that room. You can be honest about what happened without making yourself the enemy.',
        ],
      ),
      LearnArticleSection(
        heading: 'Avoidance that keeps getting bigger',
        paragraphs: [
          'Putting something off can give quick relief. But if avoiding a message, place, person, or responsibility keeps shrinking your world, the short-term relief may be costing you more later.',
          'Try making the next step smaller: open the message without replying, write one sentence, or ask someone to sit with you while you begin. You are allowed to ask for help with the part that feels stuck.',
        ],
      ),
      LearnArticleSection(
        heading: 'Look for one repair',
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
    title: 'Substances and your brain — an honest conversation',
    description:
        'Clear information about cannabis, alcohol, codeine-based syrups, tramadol, and inhalants, without fear-mongering.',
    readTime: '5 min read',
    sections: [
      LearnArticleSection(
        heading: 'No scare tactics, no pretending',
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
        heading: 'Alcohol: “it helps me relax” can be complicated',
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
    title: 'When “coping” becomes a problem',
    description:
        'A few honest questions can help you notice when relief is starting to cost you.',
    readTime: '4 min read',
    sections: [
      LearnArticleSection(
        heading: 'Coping is how we get through things',
        paragraphs: [
          'Coping can be positive, ordinary, and creative. Resting, praying, talking, moving, making music, distracting yourself for a while, or asking for help can all help you make it through a hard moment.',
          'A strategy can help today and still become a problem when it is the only strategy left, causes harm, or makes your world smaller. This is about noticing a pattern, not diagnosing yourself.',
        ],
      ),
      LearnArticleSection(
        heading: 'Ask yourself what happens next',
        paragraphs: [
          'After I use this coping strategy, do I feel more able to face the next step, or more stuck? Is it affecting my sleep, health, money, relationships, school, or work? Am I hiding it because I am worried about how it looks?',
          'Do I need more of it, or need to do it for longer, to get the same relief? What happens when I try not to do it? These questions are not a test and there is no score to pass.',
        ],
      ),
      LearnArticleSection(
        heading: 'Relief can be real and still have a cost',
        paragraphs: [
          'If a behaviour, substance, or routine gives you a break from pain, it makes sense that your mind reaches for it again. That does not make you weak. It may mean the pain needs more support than one private strategy can provide.',
          'Try to look at the whole picture with kindness. You can keep the parts that help while asking for a safer or more sustainable option for the parts that are hurting you.',
        ],
      ),
      LearnArticleSection(
        heading: 'Talk before the pattern gets bigger',
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
    title: 'Getting help in Nigeria',
    description:
        'Support is not a sign of failure. Here is how to think about the next human step.',
    readTime: '4 min read',
    sections: [
      LearnArticleSection(
        heading: 'You do not have to explain everything perfectly',
        paragraphs: [
          'Asking for help can feel exposing, especially when people around you have treated mental health as something to hide. You are allowed to ask for support before you have the right words, a formal label, or a crisis.',
          'You might begin with a trusted friend, family member, teacher, faith leader, school counsellor, community health worker, doctor, or qualified mental-health professional. Choose someone who will listen and respect your safety.',
        ],
      ),
      LearnArticleSection(
        heading: 'For planned support',
        paragraphs: [
          'A primary health centre, general hospital, teaching hospital, or qualified mental-health professional may be a starting point. The right service depends on your situation and location. A doctor or other qualified professional can help you decide what care is appropriate.',
          'MindMate’s professional directory is a request-based prototype. Its competition listings are clearly labelled demo data, not an endorsement or proof that a provider is available. A request is not a confirmed appointment.',
        ],
      ),
      LearnArticleSection(
        heading: 'For immediate danger',
        paragraphs: [
          'If someone is in immediate danger, may act on thoughts of suicide or serious self-harm, has a serious reaction to a substance, cannot be woken, or needs urgent physical care, use emergency help now. Do not rely on an app chat to manage an emergency.',
          'The Emergency Support screen includes Nigeria-wide and state options, the 112 fallback, and international choices when relevant. Numbers and services can change, so check the current options shown in the app and use the nearest emergency department when needed.',
        ],
      ),
      LearnArticleSection(
        heading: 'Make the first conversation easier',
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
    title: 'If your friend is struggling',
    description:
        'You can listen, take warning signs seriously, and bring in more support without carrying this alone.',
    readTime: '4 min read',
    sections: [
      LearnArticleSection(
        heading: 'Start with care, not an interrogation',
        paragraphs: [
          'Choose a private moment and speak about what you have noticed: “You have seemed quieter lately, and I care about you. How are you really doing?” Give them time to answer. You do not need to fill every silence.',
          'Listen for understanding rather than immediately offering a solution. You can say, “That sounds really hard,” or “Thank you for telling me.” Taking someone seriously does not mean agreeing with every conclusion they have made.',
        ],
      ),
      LearnArticleSection(
        heading: 'What to say and what not to say',
        paragraphs: [
          'Helpful words are specific and steady: “I am here with you,” “You do not have to handle this alone,” and “Can we find a trusted adult or professional together?” Ask what kind of help would feel possible right now.',
          'Avoid “cheer up,” “other people have it worse,” “just forget about it,” or accusations that they are seeking attention. Avoid promising to keep a serious safety concern secret.',
        ],
      ),
      LearnArticleSection(
        heading: 'Take safety seriously',
        paragraphs: [
          'If your friend says they may hurt themselves or someone else, has taken a dangerous substance, cannot stay safe, or is in immediate danger, involve a trusted adult, qualified professional, or emergency service. If you are both young, tell a responsible adult even if your friend asks you not to.',
          'Stay with them or help them get to a safer person and place when you can do so safely. Do not put yourself in danger or try to be the only person responsible for keeping them safe.',
        ],
      ),
      LearnArticleSection(
        heading: 'Support them without disappearing yourself',
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
];
