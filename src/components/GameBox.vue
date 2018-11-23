<template>
  <div class="game-box">
    <div class="user">
      <div class="round our-round" v-if="ownRound && !data.result">{{$t('hold')}}</div>
      <img :src="user.img">
      <p>{{$t(`Account.player[${user.index}]`)}}</p>
    </div>
    <span>VS</span>
    <div class="user" v-if="waiting">
      <img>
      <p>{{$t('Account.waiting')}}</p>
    </div>
    <div class="user" v-else>
      <div class="round opp-round" v-if="!ownRound && !data.result">{{$t('hold')}}</div>
      <img :src="opponent.img">
      <p>{{$t(`Account.player[${opponent.index}]`)}}</p>
    </div>
    <div v-if="data.result" class="result" :style="{
      'background-image': `url(${require('../assets/result_' + result + '_' + $i18n.locale + '.png')})`
    }"/>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'GameBox',
  props: ['data'],
  computed: {
    ...mapGetters({
      user: 'user',
      userByAddress: 'userByAddress',
      address: 'web3/address'
    }),
    waiting () {
      return this.data.p2 === '0x0000000000000000000000000000000000000000'
    },
    offensive () {
      return this.data.p1 === this.address
    },
    ownRound () {
      const round = this.data.board.reduce((sum, value) => {
        if (value === '1') {
          return sum + 1
        } else if (value === '2') {
          return sum - 1
        }
        return sum
      }, 1)
      return round === 2 ^ this.offensive
    },
    opponent () {
      if (this.offensive) {
        return this.userByAddress(this.data.p2)
      } else {
        return this.userByAddress(this.data.p1)
      }
    },
    result () {
      switch (this.data.result) {
        case 1:
          return this.offensive ? 'victory' : 'defeat'
        case 2:
          return this.offensive ? 'defeat' : 'victory'
        default:
          return 'draw'
      }
    }
  }
}
</script>

<style lang="stylus" scoped>
.game-box
  height 130px
  box-sizing border-box
  padding 20px
  border solid 1px #bfbfbf
  border-radius 10px
  box-shadow 0 6px 20px 0 #0001
  display flex
  position relative
  .user
    flex 0 0 60px
    position relative
  img
    display block
    width 60px
    height 60px
    border-radius 30px
    background-color #bfbfbf
  p
    display block
    font-size 14px
    color #666
    text-align center
    width 140%
    margin 10px -20% 0
  span
    flex 1 1 auto
    font-size 36px
    text-align center
    font-weight 500
    line-height 88px

.round
  position absolute
  width 50px
  height 20px
  text-align center
  background-color #fc6541
  border-radius 6px
  color #fff
  font-size 14px
  font-weight 500
.our-round
  left -16px
.opp-round
  right -16px

.result
  position absolute
  width 128px
  height 39px
  background-repeat no-repeat
  top -16px
  left 50%
  transform translateX(-50%)
  background-size contain
</style>
