__author__ = 'RIK'

import logging
logger =  logging.getLogger('game_handler')

from game.logic.constants import EptitudePeriod, EptitudeCondition, EptitudeLevel, EptitudeAttachment, EptitudeType
from game.logic.action import Action


class CardController ():

    def setScenario (self, scenario):
        self.scenario = scenario

    def setMatch (self, match):
        self.match = match

    def setClient (self, client):
        self.client = client

    def setWhiteFlag(self, flag):
        self.whiteFlag = flag

    def new_card(self):
        for card in self.match.white_hand:
            self.card = card
            self.eptitudes = card['eptitudes'][:]
            self.activate(EptitudePeriod.CARD_MODE_NEW_CARD)

        for card in self.match.black_hand:
            self.card = card
            self.eptitudes = card['eptitudes'][:]
            self.activate(EptitudePeriod.CARD_MODE_NEW_CARD)

        if self.match.whiteHeroUnit.getHealth() < self.match.whiteHeroUnit.defaultHealth:
            self.hero_wound(True)

        if self.match.blackHeroUnit.getHealth() < self.match.blackHeroUnit.defaultHealth:
            self.hero_wound(False)

        self.new_unit()



    def new_unit(self):
        for card in self.match.white_hand:
            self.card = card
            self.eptitudes = card['eptitudes'][:]
            self.activate(EptitudePeriod.CARD_MODE_NEW_UNIT)

        for card in self.match.black_hand:
            self.card = card
            self.eptitudes = card['eptitudes'][:]
            self.activate(EptitudePeriod.CARD_MODE_NEW_UNIT)

    def unit_die(self, whiteFlag):
        for card in self.match.white_hand:
            self.card = card
            self.eptitudes = card['eptitudes'][:]
            self.activate(EptitudePeriod.CARD_MODE_UNIT_DIE)

        for card in self.match.black_hand:
            self.card = card
            self.eptitudes = card['eptitudes'][:]
            self.activate(EptitudePeriod.CARD_MODE_UNIT_DIE)

    def freeze(self):
       for card in self.match.white_hand:
            self.card = card
            self.eptitudes = card['eptitudes'][:]
            self.activate(EptitudePeriod.CARD_MODE_FREEZE)

       for card in self.match.black_hand:
            self.card = card
            self.eptitudes = card['eptitudes'][:]
            self.activate(EptitudePeriod.CARD_MODE_FREEZE)

    def destroy_shield(self):
        for card in self.match.white_hand:
            self.card = card
            self.eptitudes = card['eptitudes'][:]
            self.activate(EptitudePeriod.CARD_MODE_DESTROY_SHIELD)

        for card in self.match.black_hand:
            self.card = card
            self.eptitudes = card['eptitudes'][:]
            self.activate(EptitudePeriod.CARD_MODE_DESTROY_SHIELD)

    def play_card(self):
        for card in self.match.white_hand:
            self.card = card
            self.eptitudes = card['eptitudes'][:]
            self.activate(EptitudePeriod.CARD_MODE_PLAY_CARD)

        for card in self.match.black_hand:
            self.card = card
            self.eptitudes = card['eptitudes'][:]
            self.activate(EptitudePeriod.CARD_MODE_PLAY_CARD)

    def hero_wound(self, heroWhiteFlag):
        for card in self.match.white_hand:
            self.card = card
            self.eptitudes = card['eptitudes'][:]
            if heroWhiteFlag == card['whiteFlag']:
                self.activate(EptitudePeriod.CARD_MODE_PLAYER_HERO_WOUND)
            else:
                self.activate(EptitudePeriod.CARD_MODE_OPPONENT_HERO_WOUND)


        for card in self.match.black_hand:
            self.card = card
            self.eptitudes = card['eptitudes'][:]
            if heroWhiteFlag == card['whiteFlag']:
                self.activate(EptitudePeriod.CARD_MODE_PLAYER_HERO_WOUND)
            else:
                self.activate(EptitudePeriod.CARD_MODE_OPPONENT_HERO_WOUND)




    def activate (self, period):
        if len(self.eptitudes):
            eptitude = self.eptitudes[0]
            del  self.eptitudes[0]

            if period == eptitude['period']:

               if eptitude['type'] == EptitudeType.DECREASE_PRICE_DEPENDS_ON_TOKENS:
                   logger.debug ('CardController activate: eptitude.type: DECREASE_PRICE_DEPENDS_ON_TOKENS')
                   self.decrease_price_depends_on_tokens()

               if eptitude['type'] == EptitudeType.DECREASE_PRICE_DEPENDS_ON_RACE_TOKENS:
                   logger.debug ('CardController activate: eptitude.type: DECREASE_PRICE_DEPENDS_ON_RACE_TOKENS')
                   self.decrease_price_depends_on_race_tokens(eptitude)

               if eptitude['type'] == EptitudeType.DECREASE_PRICE_DEPENDS_ON_SHIELD_TOKENS:
                   logger.debug ('CardController activate: eptitude.type: DECREASE_PRICE_DEPENDS_ON_SHIELD_TOKENS')
                   self.decrease_price_depends_on_shield_tokens(eptitude)

               if eptitude['type'] == EptitudeType.DECREASE_PRICE_DEPENDS_ON_PLAYER_CARDS:
                   logger.debug ('CardController activate: eptitude.type: DECREASE_PRICE_DEPENDS_ON_PLAYER_CARDS')
                   self.decrease_price_depends_on_player_cards()

               if eptitude['type'] == EptitudeType.DECREASE_PRICE_DEPENDS_ON_OPPONENT_CARDS:
                   logger.debug ('CardController activate: eptitude.type: DECREASE_PRICE_DEPENDS_ON_OPPONENT_CARDS')
                   self.decrease_price_depends_on_opponent_cards()

               if eptitude['type'] == EptitudeType.DECREASE_PRICE_DEPENDS_ON_HERO_HEALTH:
                   logger.debug ('CardController activate: eptitude.type: DECREASE_PRICE_DEPENDS_ON_HERO_HEALTH')
                   self.decrease_price_depends_on_hero_health()

               if eptitude['type'] == EptitudeType.DECREASE_PRICE_DEPENDS_ON_DIE_UNITS:
                   logger.debug ('CardController activate: eptitude.type: DECREASE_PRICE_DEPENDS_ON_DIE_UNITS')
                   self.decrease_price_depends_on_die_units(eptitude)

               if eptitude['type'] == EptitudeType.DECREASE_PRICE_DEPENDS_ON_FROZEN_TOKENS:
                   logger.debug ('CardController activate: eptitude.type: DECREASE_PRICE_DEPENDS_ON_DIE_UNITS')
                   self.decrease_price_depends_on_freeze_tokens(eptitude)






            self.activate(period)

    def decrease_price_depends_on_player_cards(self):
        card = self.card
        attachment, index = self.match.initCardAttachment(card, self.whiteFlag)
        if card['whiteFlag']:
            value = len(self.match.white_hand)
        else:
            value = len(self.match.black_hand)
        # меняем цену в самой карте
        if value > card['defaultPrice']:
            value = card['defaultPrice']
        card['price'] = card['defaultPrice'] - value

        # оповещаем клиент
        action = {}
        action['type'] = Action.CHANGE_CARD_PRICE
        action['client'] = self.client
        action['endAnimationFlag'] = True
        action['attachment'] = attachment
        action['index'] = index
        action['price'] = card['price'] + card['priceMixin']
        self.scenario.append(action)

        if self.whiteFlag:
            row = self.match.whiteUnitRow
        else:
            row = self.match.blackUnitRow

        if len(row) < 7:
            action = {}
            action['type'] = Action.GLOW_CARDS
            action['client'] = self.client
            action['endAnimationFlag'] = False
            self.scenario.append(action)

    def decrease_price_depends_on_opponent_cards(self):
        card = self.card
        attachment, index = self.match.initCardAttachment(card, self.whiteFlag)

        if card['whiteFlag']:
            value = len(self.match.black_hand)
        else:
            value = len(self.match.white_hand)
        # меняем цену в самой карте
        if value > card['defaultPrice']:
            value = card['defaultPrice']
        card['price'] = card['defaultPrice'] - value


        # оповещаем клиент
        action = {}
        action['type'] = Action.CHANGE_CARD_PRICE
        action['client'] = self.client
        action['endAnimationFlag'] = True
        action['attachment'] = attachment
        action['index'] = index
        action['price'] = card['price'] + card['priceMixin']
        self.scenario.append(action)

        if self.whiteFlag:
            row = self.match.whiteUnitRow
        else:
            row = self.match.blackUnitRow

        if len(row) < 7:
            action = {}
            action['type'] = Action.GLOW_CARDS
            action['client'] = self.client
            action['endAnimationFlag'] = False
            self.scenario.append(action)

    def decrease_price_depends_on_tokens(self):
        card = self.card
        attachment, index = self.match.initCardAttachment(card, self.whiteFlag)

        value = len(self.match.whiteUnitRow) + len(self.match.blackUnitRow)

        # меняем цену в самой карте
        if value > card['defaultPrice']:
            value = card['defaultPrice']
        card['price'] = card['defaultPrice'] - value


        # оповещаем клиент
        action = {}
        action['type'] = Action.CHANGE_CARD_PRICE
        action['client'] = self.client
        action['endAnimationFlag'] = True
        action['attachment'] = attachment
        action['index'] = index
        action['price'] = card['price'] + card['priceMixin']
        self.scenario.append(action)

        if self.whiteFlag:
            row = self.match.whiteUnitRow
        else:
            row = self.match.blackUnitRow

        if len(row) < 7:
            action = {}
            action['type'] = Action.GLOW_CARDS
            action['client'] = self.client
            action['endAnimationFlag'] = False
            self.scenario.append(action)

    def decrease_price_depends_on_hero_health(self):
        card = self.card
        attachment, index = self.match.initCardAttachment(card, self.whiteFlag)

        if card['whiteFlag']:
            hero = self.match.whiteHeroUnit
        else:
            hero = self.match.blackHeroUnit

        value = hero.defaultHealth - hero.getHealth()

        # меняем цену в самой карте
        if value > card['defaultPrice']:
            value = card['defaultPrice']
        card['price'] = card['defaultPrice'] - value


        # оповещаем клиент
        action = {}
        action['type'] = Action.CHANGE_CARD_PRICE
        action['client'] = self.client
        action['endAnimationFlag'] = True
        action['attachment'] = attachment
        action['index'] = index
        action['price'] = card['price'] + card['priceMixin']
        self.scenario.append(action)

        if self.whiteFlag:
            row = self.match.whiteUnitRow
        else:
            row = self.match.blackUnitRow

        if len(row) < 7:
            action = {}
            action['type'] = Action.GLOW_CARDS
            action['client'] = self.client
            action['endAnimationFlag'] = False
            self.scenario.append(action)

    def decrease_price_depends_on_race_tokens(self, eptitude):
        card = self.card
        attachment, index = self.match.initCardAttachment(card, self.whiteFlag)

        value = 0
        for unit in self.match.whiteUnitRow:
            if unit.race.id == eptitude['race']:
                value += 1

        for unit in self.match.blackUnitRow:
             if unit.race.id == eptitude['race']:
                value += 1

        value *= eptitude['power']

        # меняем цену в самой карте
        if value > card['defaultPrice']:
            value = card['defaultPrice']
        card['price'] = card['defaultPrice'] - value


        # оповещаем клиент
        action = {}
        action['type'] = Action.CHANGE_CARD_PRICE
        action['client'] = self.client
        action['endAnimationFlag'] = True
        action['attachment'] = attachment
        action['index'] = index
        action['price'] = card['price'] + card['priceMixin']
        self.scenario.append(action)

        if self.whiteFlag:
            row = self.match.whiteUnitRow
        else:
            row = self.match.blackUnitRow

        if len(row) < 7:
            action = {}
            action['type'] = Action.GLOW_CARDS
            action['client'] = self.client
            action['endAnimationFlag'] = False
            self.scenario.append(action)

    def decrease_price_depends_on_shield_tokens(self, eptitude):
        card = self.card
        attachment, index = self.match.initCardAttachment(card, self.whiteFlag)

        value = 0
        for unit in self.match.whiteUnitRow:
            if unit.shield:
                value += 1

        for unit in self.match.blackUnitRow:
             if unit.shield:
                value += 1

        value *= eptitude['power']

        # меняем цену в самой карте
        if value > card['defaultPrice']:
            value = card['defaultPrice']
        card['price'] = card['defaultPrice'] - value


        # оповещаем клиент
        action = {}
        action['type'] = Action.CHANGE_CARD_PRICE
        action['client'] = self.client
        action['endAnimationFlag'] = True
        action['attachment'] = attachment
        action['index'] = index
        action['price'] = card['price'] + card['priceMixin']
        self.scenario.append(action)

        if self.whiteFlag:
            row = self.match.whiteUnitRow
        else:
            row = self.match.blackUnitRow

        if len(row) < 7:
            action = {}
            action['type'] = Action.GLOW_CARDS
            action['client'] = self.client
            action['endAnimationFlag'] = False
            self.scenario.append(action)

    def decrease_price_depends_on_freeze_tokens(self, eptitude):
        card = self.card
        attachment, index = self.match.initCardAttachment(card, self.whiteFlag)

        value = 0
        for unit in self.match.whiteUnitRow:
            if unit.freeze:
                value += 1

        for unit in self.match.blackUnitRow:
             if unit.freeze:
                value += 1

        if self.match.whiteHeroUnit.freeze:
            value += 1

        if self.match.blackHeroUnit.freeze:
            value += 1

        value *= eptitude['power']

        # меняем цену в самой карте
        if value > card['defaultPrice']:
            value = card['defaultPrice']
        card['price'] = card['defaultPrice'] - value


        # оповещаем клиент
        action = {}
        action['type'] = Action.CHANGE_CARD_PRICE
        action['client'] = self.client
        action['endAnimationFlag'] = True
        action['attachment'] = attachment
        action['index'] = index
        action['price'] = card['price'] + card['priceMixin']
        self.scenario.append(action)

        if self.whiteFlag:
            row = self.match.whiteUnitRow
        else:
            row = self.match.blackUnitRow

        if len(row) < 7:
            action = {}
            action['type'] = Action.GLOW_CARDS
            action['client'] = self.client
            action['endAnimationFlag'] = False
            self.scenario.append(action)

    def decrease_price_depends_on_die_units(self, eptitude):
        card = self.card
        attachment, index = self.match.initCardAttachment(card, self.whiteFlag)


        value = self.match.dieUnitsIndex
        value *= eptitude['power']

        # меняем цену в самой карте
        if value > card['defaultPrice']:
            value = card['defaultPrice']
        card['price'] = card['defaultPrice'] - value


        # оповещаем клиент
        action = {}
        action['type'] = Action.CHANGE_CARD_PRICE
        action['client'] = self.client
        action['endAnimationFlag'] = True
        action['attachment'] = attachment
        action['index'] = index
        action['price'] = card['price'] + card['priceMixin']
        self.scenario.append(action)

        if self.whiteFlag:
            row = self.match.whiteUnitRow
        else:
            row = self.match.blackUnitRow

        if len(row) < 7:
            action = {}
            action['type'] = Action.GLOW_CARDS
            action['client'] = self.client
            action['endAnimationFlag'] = False
            self.scenario.append(action)





