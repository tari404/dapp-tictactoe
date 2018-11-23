<template>
  <div id="app">
    <nav>
      <div class="main-width">
        <h1>{{$t('title')}}</h1>
        <div class="game-i18n">
          <span :class="{ 'focus': $i18n.locale === 'sc' }"
            @click="toggleLang('sc')">简体中文</span>
          <span :class="{ 'focus': $i18n.locale === 'en' }"
            @click="toggleLang('en')">English</span>
        </div>
      </div>
    </nav>
    <section v-if="beforeEnter">
      <div class="game-intro game-content main-width">
        <div class="game-box-map">
          <span v-for="i in 9" :key="i" :class="{
            'game-box-o': board[i - 1] === 1,
            'game-box-x': board[i - 1] === 2
          }" />
        </div>
        <p>{{$t('intro')}}<br>{{$t('introduction')}}</p>
        <div class="game-intro-start" @click="start">{{$t('start')}}</div>
      </div>
    </section>
    <section v-else-if="beforeLogin">
      <div class="game-login game-content main-width">
        <h2>{{$t('login')}}</h2>
        <p>{{$t('Account.select')}}</p>
        <div class="game-login-select" :class="{
          'game-login-select-open': showOptions
        }" @click="clickSelector">
          <ul class="game-login-options" :style="{
            'transform': `translateY(${-selected * 80}px)`
          }">
            <li v-for="(user, index) in defaultUsers" :key="index"
              @click="selectOption($event, index)">
              <img :src="user.img">
              <span>{{$t(`Account.player[${user.index}]`)}}</span>
            </li>
          </ul>
        </div>
        <div class="game-login-start" @click="login">{{$t('start')}}</div>
      </div>
    </section>
    <section v-else-if="!beforeRefresh">
      <game-list @focus="onFocusGame" />
    </section>
    <notice />
    <game v-if="focusGame" :data="focusGame" @close="onBlurGame" />
  </div>
</template>

<script>
import { mapState, mapGetters, mapActions } from 'vuex'
import Notice from '@/components/Notice'
import GameList from '@/components/GameList'
import Game from '@/components/Game'

export default {
  name: 'App',
  data () {
    return {
      board: [2, 1, 0, 1, 1, 2, 0, 2, 0],
      beforeEnter: true,
      beforeLogin: true,
      beforeRefresh: false,
      userIndex: 0,

      showOptions: false,
      selected: 0,

      focusGame: null
    }
  },
  computed: {
    ...mapState({
      defaultUsers: state => state.defaultUsers
    })
  },
  created () {
    this.checkNetwork()
    this.queryGameCount()
  },
  methods: {
    ...mapActions({
      checkNetwork: 'web3/checkNetwork',
      queryGameCount: 'web3/queryGameCount',
      updateUser: 'web3/updateUser'
    }),
    toggleLang (locale) {
      this.$i18n.locale = locale
      document.title = this.$t('title')
    },
    start () {
      this.beforeEnter = false
    },
    login () {
      this.updateUser(this.selected)
      this.beforeLogin = false
    },
    clickSelector (event) {
      if (!this.showOptions) {
        this.showOptions = true
        event.stopPropagation()
        document.addEventListener('click', this.closeSelector)
      }
    },
    closeSelector () {
      this.showOptions = false
      document.removeEventListener('click', this.closeSelector)
    },
    selectOption (event, index) {
      if (!this.showOptions) {
        return
      }
      this.selected = index
    },
    onFocusGame (game) {
      this.focusGame = game
    },
    onBlurGame () {
      this.focusGame = null
    }
  },
  components: {
    Notice,
    GameList,
    Game
  }
}
</script>

<style lang="stylus">
body
  margin 0
  background-color #f0f4f8
  font-family Avenir,Helvetica,Arial,sans-serif
  -webkit-text-size-adjust none
body::-webkit-scrollbar
  display none
  width 0
  height 0
  opacity 0
a
  color inherit
ul
  margin 0
  padding 0
li
  list-style none

.main-width
  margin auto
  flex 0 1 1200px
  min-width 480px
  box-sizing border-box

.game-blank
  line-height 20px

nav
  height 90px
  padding 0 15px
  display flex
  margin-bottom 60px
  background-color #fff
  box-shadow 0 2px 4px #0001
  h1
    color #333
    font-size 20px
    font-weight 600
    line-height 40px
    text-align center
  .main-width
    position relative
.game-i18n
  position absolute
  top 50%
  right 0
  transform translateY(-50%)
  padding 0 4px
  font-size 14px
  display flex
  span
    display block
    line-height 30px
    height 30px
    border solid 1px #bfbfbf
    box-sizing border-box
    color #666
    cursor pointer
  span:first-child
    border-right none
    padding 0 4px 0 8px
    border-radius 15px 0 0 15px
  span:last-child
    border-left none
    padding 0 8px 0 4px
    border-radius 0 15px 15px 0
  .focus
    background-color #1e64b4
    color #fff
    border-color #1e64b4

section
  margin 20px 10px
  display flex
label
  display block
  line-height 40px
  width 90px
  height 40px
input
  font-family inherit
  font-size inherit
  box-sizing border-box
  border-radius 3px
  border 1px solid #ddd
  font-size 16px
  outline none
  height 40px
  margin 0
  padding 0 9px

.game-content
  background-color #fff
  border-radius 10px
  background-color #fff
  padding 40px 30px
  box-shadow 0 2px 4px #0001
  margin-bottom 20px
  position relative

.game-notice
  margin-top 4px
  font-size 12px
  color #666

.game-intro
  padding 20px 100px
  p
    font-size 18px
    line-height 30px
    color #666
  .game-intro-start
    width 300px
    height 60px
    background #1E64B4
    border-radius 10px
    line-height 60px
    text-align center
    color #fff
    font-size 18px
    cursor pointer
    margin 100px auto 80px

.game-box-map
  width 100px
  margin 40px auto
  padding 4px
  border-radius 4px
  background-color #eee
  display grid
  grid-template-columns repeat(3, 32px)
  grid-gap 2px
  span
    display block
    background-color #fff
    height 32px
    position relative
    &:after
      width 32px
      height 32px
      position absolute
      top 0
      left 0
      text-align center
      font-size 24px
      line-height 35px
      font-weight bold
.game-box-o:after
  content 'O'
  color #ca0000
.game-box-x:after
  content 'X'
  color #0000ca

.game-login
  flex 0 1 800px
  margin auto
  padding 20px 150px
  h2
    margin 60px auto
    font-weight 400
    text-align center
    font-size 24px
    line-height 30px
    color #333
  p
    margin 20px 0
    font-size 18px
    line-height 20px
    color #666
  .game-login-start
    width 300px
    height 60px
    background #1E64B4
    border-radius 10px
    line-height 60px
    text-align center
    color #fff
    font-size 18px
    cursor pointer
    margin 60px auto 80px

.game-login-select
  cursor pointer
  height 80px
  border solid 1px #d2d2d2
  border-radius 10px
  overflow hidden
  position relative
  &:after
    content ''
    position absolute
    right 24px
    top 35px
    width 0
    height 0
    border-top solid 13px #bfbfbf
    border-left solid 10px transparent
    border-right solid 10px transparent
    transition transform .4s, opacity .4s
.game-login-select-open
  overflow visible
  li:nth-child(even)
    background-color #f9f9f9
  &:after
    transform scaleY(0)
    opacity 0
.game-login-options
  border solid 1px #d2d2d2
  border-radius 10px
  overflow hidden
  position absolute
  left -1px
  top -1px
  width 100%
  transition transform .4s
  li
    height 80px
    line-height 80px
    display flex
    background-color #fff
  img
    width 40px
    height 40px
    border-radius 20px
    margin 20px 24px
  span
    font-size 18px
    color #333
</style>
