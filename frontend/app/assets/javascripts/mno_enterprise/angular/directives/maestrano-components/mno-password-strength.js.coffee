"use strict"

angular.module("maestrano.components.mno-password-strength", [
]).directive "mnoPasswordStrength", ->
  require: "ngModel"
  restrict: "A"
  scope:
    passwordScore: '=' # outject score

  link: (scope,elem, attrs, ctrl) ->
    mesureStrength = (p) ->
      matches =
        pos: {}
        neg: {}

      counts =
        pos: {}
        neg:
          seqLetter: 0
          seqNumber: 0
          seqSymbol: 0

      tmp = undefined
      strength = 0
      letters = "abcdefghijklmnopqrstuvwxyz"
      numbers = "01234567890"
      symbols = "\\!@#$%&/()=?¿"
      back = undefined
      forth = undefined
      i = undefined
      if p
        
        # Benefits
        matches.pos.lower = p.match(/[a-z]/g)
        matches.pos.upper = p.match(/[A-Z]/g)
        matches.pos.numbers = p.match(/\d/g)
        matches.pos.symbols = p.match(/[$-/:-?{-~!^_`\[\]]/g)
        matches.pos.middleNumber = p.slice(1, -1).match(/\d/g)
        matches.pos.middleSymbol = p.slice(1, -1).match(/[$-/:-?{-~!^_`\[\]]/g)
        counts.pos.lower = (if matches.pos.lower then matches.pos.lower.length else 0)
        counts.pos.upper = (if matches.pos.upper then matches.pos.upper.length else 0)
        counts.pos.numbers = (if matches.pos.numbers then matches.pos.numbers.length else 0)
        counts.pos.symbols = (if matches.pos.symbols then matches.pos.symbols.length else 0)
        tmp = _.reduce(counts.pos, (memo, val) ->
          
          # if has count will add 1
          memo + Math.min(1, val)
        , 0)
        counts.pos.numChars = p.length
        tmp += (if (counts.pos.numChars >= 8) then 1 else 0)
        counts.pos.requirements = (if (tmp >= 3) then tmp else 0)
        counts.pos.middleNumber = (if matches.pos.middleNumber then matches.pos.middleNumber.length else 0)
        counts.pos.middleSymbol = (if matches.pos.middleSymbol then matches.pos.middleSymbol.length else 0)
        
        # Deductions
        matches.neg.consecLower = p.match(/(?=([a-z]{2}))/g)
        matches.neg.consecUpper = p.match(/(?=([A-Z]{2}))/g)
        matches.neg.consecNumbers = p.match(/(?=(\d{2}))/g)
        matches.neg.onlyNumbers = p.match(/^[0-9]*$/g)
        matches.neg.onlyLetters = p.match(/^([a-z]|[A-Z])*$/g)
        counts.neg.consecLower = (if matches.neg.consecLower then matches.neg.consecLower.length else 0)
        counts.neg.consecUpper = (if matches.neg.consecUpper then matches.neg.consecUpper.length else 0)
        counts.neg.consecNumbers = (if matches.neg.consecNumbers then matches.neg.consecNumbers.length else 0)
        
        # sequential letters (back and forth)
        i = 0
        while i < letters.length - 2
          p2 = p.toLowerCase()
          forth = letters.substring(i, parseInt(i + 3))
          back = _.str.reverse(forth)
          counts.neg.seqLetter++  if p2.indexOf(forth) isnt -1 or p2.indexOf(back) isnt -1
          i++
        
        # sequential numbers (back and forth)
        i = 0
        while i < numbers.length - 2
          forth = numbers.substring(i, parseInt(i + 3))
          back = _.str.reverse(forth)
          counts.neg.seqNumber++  if p.indexOf(forth) isnt -1 or p.toLowerCase().indexOf(back) isnt -1
          i++
        
        # sequential symbols (back and forth)
        i = 0
        while i < symbols.length - 2
          forth = symbols.substring(i, parseInt(i + 3))
          back = _.str.reverse(forth)
          counts.neg.seqSymbol++  if p.indexOf(forth) isnt -1 or p.toLowerCase().indexOf(back) isnt -1
          i++
        
        # repeated chars
        counts.neg.repeated = _.chain(p.toLowerCase().split("")).countBy((val) ->
          val
        ).reject((val) ->
          val is 1
        ).reduce((memo, val) ->
          memo + val
        , 0).value()
        
        # Calculations
        strength += counts.pos.numChars * 4
        strength += (counts.pos.numChars - counts.pos.upper) * 2  if counts.pos.upper
        strength += (counts.pos.numChars - counts.pos.lower) * 2  if counts.pos.lower
        strength += counts.pos.numbers * 4  if counts.pos.upper or counts.pos.lower
        strength += counts.pos.symbols * 6
        strength += (counts.pos.middleSymbol + counts.pos.middleNumber) * 2
        strength += counts.pos.requirements * 2
        strength -= counts.neg.consecLower * 2
        strength -= counts.neg.consecUpper * 2
        strength -= counts.neg.consecNumbers * 2
        strength -= counts.neg.seqNumber * 3
        strength -= counts.neg.seqLetter * 3
        strength -= counts.neg.seqSymbol * 3
        strength -= counts.pos.numChars  if matches.neg.onlyNumbers
        strength -= counts.pos.numChars  if matches.neg.onlyLetters
        strength -= (counts.neg.repeated / counts.pos.numChars) * 10  if counts.neg.repeated
      Math.max 0, Math.min(100, Math.round(strength))

    getPwStrength = (s) ->
      switch Math.round(s / 20)
        when 0, 1
          "weak"
        when 2,3
          "good"
        when 4,5
          "secure"
    
    getClass = (s) ->
      switch getPwStrength(s)
        when 'weak'
          "danger"
        when 'good'
          "warning"
        when 'secure'
          "success"
    
    isPwStrong = (s) ->
      switch getPwStrength(s)
        when 'weak'
          false
        else
          true
    
    scope.$watch (-> ctrl.$modelValue), ->
      scope.value = mesureStrength(ctrl.$modelValue)
      scope.pwStrength = getPwStrength(scope.value)
      ctrl.$setValidity('password-strength', isPwStrong(scope.value))
      
      if scope.passwordScore?
        scope.passwordScore.value = scope.pwStrength 
        scope.passwordScore.class = getClass(scope.value)
        scope.passwordScore.showTip = (ctrl.$modelValue? && ctrl.$modelValue != '' && !isPwStrong(scope.value))
      

    return
