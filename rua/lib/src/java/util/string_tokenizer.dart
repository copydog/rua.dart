import 'package:rua/src/java/lang/character.dart';
import 'package:rua/src/java/lang/null_pointer_exception.dart';
import 'package:rua/src/java/util/no_such_element_exception.dart';

/**
 * The string tokenizer class allows an application to break a
 * string into tokens. The tokenization method is much simpler than
 * the one used by the <code>StreamTokenizer</code> class. The
 * <code>StringTokenizer</code> methods do not distinguish among
 * identifiers, numbers, and quoted strings, nor do they recognize
 * and skip comments.
 * <p>
 * The set of delimiters (the characters that separate tokens) may
 * be specified either at creation time or on a per-token basis.
 * <p>
 * An instance of <code>StringTokenizer</code> behaves in one of two
 * ways, depending on whether it was created with the
 * <code>returnDelims</code> flag having the value <code>true</code>
 * or <code>false</code>:
 * <ul>
 * <li>If the flag is <code>false</code>, delimiter characters serve to
 *     separate tokens. A token is a maximal sequence of consecutive
 *     characters that are not delimiters.
 * <li>If the flag is <code>true</code>, delimiter characters are themselves
 *     considered to be tokens. A token is thus either one delimiter
 *     character, or a maximal sequence of consecutive characters that are
 *     not delimiters.
 * </ul><p>
 * A <tt>StringTokenizer</tt> object internally maintains a current
 * position within the string to be tokenized. Some operations advance this
 * current position past the characters processed.<p>
 * A token is returned by taking a substring of the string that was used to
 * create the <tt>StringTokenizer</tt> object.
 * <p>
 * The following is one example of the use of the tokenizer. The code:
 * <blockquote><pre>
 *     StringTokenizer st = new StringTokenizer("this is a test");
 *     while (st.hasMoreTokens()) {
 *         System.out.println(st.nextToken());
 *     }
 * </pre></blockquote>
 * <p>
 * prints the following output:
 * <blockquote><pre>
 *     this
 *     is
 *     a
 *     test
 * </pre></blockquote>
 *
 * <p>
 * <tt>StringTokenizer</tt> is a legacy class that is retained for
 * compatibility reasons although its use is discouraged in new code. It is
 * recommended that anyone seeking this functionality use the <tt>split</tt>
 * method of <tt>String</tt> or the java.util.regex package instead.
 * <p>
 * The following example illustrates how the <tt>String.split</tt>
 * method can be used to break up a string into its basic tokens:
 * <blockquote><pre>
 *     String[] result = "this is a test".split("\\s");
 *     for (int x=0; x&lt;result.length; x++)
 *         System.out.println(result[x]);
 * </pre></blockquote>
 * <p>
 * prints the following output:
 * <blockquote><pre>
 *     this
 *     is
 *     a
 *     test
 * </pre></blockquote>
 *
 * @author  unascribed
 * @see     java.io.StreamTokenizer
 * @since   JDK1.0
 */
class StringTokenizer {
  int _currentPosition;
  int _newPosition;
  int _maxPosition;
  String _str;
  String _delimiters;
  bool _retDelims;
  bool _delimsChanged;

  /**
   * maxDelimCodePoint stores the value of the delimiter character with the
   * highest value. It is used to optimize the detection of delimiter
   * characters.
   *
   * It is unlikely to provide any optimization benefit in the
   * hasSurrogates case because most string characters will be
   * smaller than the limit, but we keep it so that the two code
   * paths remain similar.
   */
  int _maxDelimCodePoint;

  /**
   * If delimiters include any surrogates (including surrogate
   * pairs), hasSurrogates is true and the tokenizer uses the
   * different code path. This is because String.indexOf(int)
   * doesn't handle unpaired surrogates as a single character.
   */
  bool _hasSurrogates = false;

  /**
   * When hasSurrogates is true, delimiters are converted to code
   * points and isDelimiter(int) is used to determine if the given
   * codepoint is a delimiter.
   */
  List<int> _delimiterCodePoints;

  /**
   * Set maxDelimCodePoint to the highest char in the delimiter set.
   */
  void _setMaxDelimCodePoint() {
    if (_delimiters == null) {
      _maxDelimCodePoint = 0;
      return;
    }

    int m = 0;
    int c;
    int count = 0;
    for (int i = 0; i < _delimiters.length; i += Character.charCount(c)) {
      c = _delimiters.codeUnitAt(i);
      if (c >= Character.MIN_HIGH_SURROGATE && c <= Character.MAX_LOW_SURROGATE) {
        c = _delimiters.codeUnitAt(i);
        _hasSurrogates = true;
      }
      if (m < c) m = c;
      count++;
    }
    _maxDelimCodePoint = m;

    if (_hasSurrogates) {
      _delimiterCodePoints = new List<int>();
      for (int i = 0, j = 0; i < count; i++, j += Character.charCount(c)) {
        c = _delimiters.codeUnitAt(j);
        _delimiterCodePoints[i] = c;
      }
    }
  }

  /**
   * Constructs a string tokenizer for the specified string. All
   * characters in the <code>delim</code> argument are the delimiters
   * for separating tokens.
   * <p>
   * If the <code>returnDelims</code> flag is <code>true</code>, then
   * the delimiter characters are also returned as tokens. Each
   * delimiter is returned as a string of length one. If the flag is
   * <code>false</code>, the delimiter characters are skipped and only
   * serve as separators between tokens.
   * <p>
   * Note that if <tt>delim</tt> is <tt>null</tt>, this constructor does
   * not throw an exception. However, trying to invoke other methods on the
   * resulting <tt>StringTokenizer</tt> may result in a
   * <tt>NullPointerException</tt>.
   *
   * @param   str            a string to be parsed.
   * @param   delim          the delimiters.
   * @param   returnDelims   flag indicating whether to return the delimiters
   *                         as tokens.
   * @exception NullPointerException if str is <CODE>null</CODE>
   */
  StringTokenizer(String str, [String delim = " \t\n\r\f", bool returnDelims = false]) {
    _currentPosition = 0;
    _newPosition = -1;
    _delimsChanged = false;
    this._str = str;
    _maxPosition = str.length;
    _delimiters = delim;
    _retDelims = returnDelims;
    _setMaxDelimCodePoint();
  }

  /**
   * Skips delimiters starting from the specified position. If retDelims
   * is false, returns the index of the first non-delimiter character at or
   * after startPos. If retDelims is true, startPos is returned.
   */
  int skipDelimiters(int startPos) {
    if (_delimiters == null) throw new NullPointerException();

    int position = startPos;
    while (!_retDelims && position < _maxPosition) {
      if (!_hasSurrogates) {
        String c = _str[position];
        if ((c.codeUnitAt(0) > _maxDelimCodePoint) || (_delimiters.indexOf(c) < 0)) break;
        position++;
      } else {
        int c = _str.codeUnitAt(position);
        if ((c > _maxDelimCodePoint) || !_isDelimiter(c)) {
          break;
        }
        position += Character.charCount(c);
      }
    }
    return position;
  }

  /**
   * Skips ahead from startPos and returns the index of the next delimiter
   * character encountered, or maxPosition if no such delimiter is found.
   */
  int scanToken(int startPos) {
    int position = startPos;
    while (position < _maxPosition) {
      if (!_hasSurrogates) {
        String c = _str[position];
        if ((c.codeUnitAt(0) <= _maxDelimCodePoint) && (_delimiters.indexOf(c) >= 0)) break;
        position++;
      } else {
        int c = _str.codeUnitAt(position);
        if ((c <= _maxDelimCodePoint) && _isDelimiter(c)) break;
        position += Character.charCount(c);
      }
    }
    if (_retDelims && (startPos == position)) {
      if (!_hasSurrogates) {
        String c = _str[position];
        if ((c.codeUnitAt(0) <= _maxDelimCodePoint) && (_delimiters.indexOf(c) >= 0)) position++;
      } else {
        int c = _str.codeUnitAt(position);
        if ((c <= _maxDelimCodePoint) && _isDelimiter(c)) position += Character.charCount(c);
      }
    }
    return position;
  }

  bool _isDelimiter(int codePoint) {
    for (int i = 0; i < _delimiterCodePoints.length; i++) {
      if (_delimiterCodePoints[i] == codePoint) {
        return true;
      }
    }
    return false;
  }

  /**
   * Tests if there are more tokens available from this tokenizer's string.
   * If this method returns <tt>true</tt>, then a subsequent call to
   * <tt>nextToken</tt> with no argument will successfully return a token.
   *
   * @return  <code>true</code> if and only if there is at least one token
   *          in the string after the current position; <code>false</code>
   *          otherwise.
   */
  bool hasMoreTokens() {
    /*
         * Temporarily store this position and use it in the following
         * nextToken() method only if the delimiters haven't been changed in
         * that nextToken() invocation.
         */
    _newPosition = skipDelimiters(_currentPosition);
    return (_newPosition < _maxPosition);
  }

  /**
   * Returns the next token from this string tokenizer.
   *
   * @return     the next token from this string tokenizer.
   * @exception  NoSuchElementException  if there are no more tokens in this
   *               tokenizer's string.
   */
  String nextToken() {
    /*
         * If next position already computed in hasMoreElements() and
         * delimiters have changed between the computation and this invocation,
         * then use the computed value.
         */

    _currentPosition =
        (_newPosition >= 0 && !_delimsChanged) ? _newPosition : skipDelimiters(_currentPosition);

    /* Reset these anyway */
    _delimsChanged = false;
    _newPosition = -1;

    if (_currentPosition >= _maxPosition) throw new NoSuchElementException();
    int start = _currentPosition;
    _currentPosition = scanToken(_currentPosition);
    return _str.substring(start, _currentPosition);
  }

  /**
   * Returns the next token in this string tokenizer's string. First,
   * the set of characters considered to be delimiters by this
   * <tt>StringTokenizer</tt> object is changed to be the characters in
   * the string <tt>delim</tt>. Then the next token in the string
   * after the current position is returned. The current position is
   * advanced beyond the recognized token.  The new delimiter set
   * remains the default after this call.
   *
   * @param      delim   the new delimiters.
   * @return     the next token, after switching to the new delimiter set.
   * @exception  NoSuchElementException  if there are no more tokens in this
   *               tokenizer's string.
   * @exception NullPointerException if delim is <CODE>null</CODE>
   */
  String nextToken_(String delim) {
    _delimiters = delim;

    /* delimiter string specified, so set the appropriate flag. */
    _delimsChanged = true;

    _setMaxDelimCodePoint();
    return nextToken();
  }

  /**
   * Returns the same value as the <code>hasMoreTokens</code>
   * method. It exists so that this class can implement the
   * <code>Enumeration</code> interface.
   *
   * @return  <code>true</code> if there are more tokens;
   *          <code>false</code> otherwise.
   * @see     java.util.Enumeration
   * @see     java.util.StringTokenizer#hasMoreTokens()
   */
  bool hasMoreElements() {
    return hasMoreTokens();
  }

  /**
   * Returns the same value as the <code>nextToken</code> method,
   * except that its declared return value is <code>Object</code> rather than
   * <code>String</code>. It exists so that this class can implement the
   * <code>Enumeration</code> interface.
   *
   * @return     the next token in the string.
   * @exception  NoSuchElementException  if there are no more tokens in this
   *               tokenizer's string.
   * @see        java.util.Enumeration
   * @see        java.util.StringTokenizer#nextToken()
   */
  Object nextElement() {
    return nextToken();
  }

  /**
   * Calculates the number of times that this tokenizer's
   * <code>nextToken</code> method can be called before it generates an
   * exception. The current position is not advanced.
   *
   * @return  the number of tokens remaining in the string using the current
   *          delimiter set.
   * @see     java.util.StringTokenizer#nextToken()
   */
  int countTokens() {
    int count = 0;
    int currpos = _currentPosition;
    while (currpos < _maxPosition) {
      currpos = skipDelimiters(currpos);
      if (currpos >= _maxPosition) break;
      currpos = scanToken(currpos);
      count++;
    }
    return count;
  }
}
