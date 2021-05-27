function y = factor(varargin)
% Fixes different output for symbolic input in Octave compared to Matlab, by using the two-output
% version in Octave
if ~isa(varargin{1},'sym')
    y = builtin('factor', varargin{:});
else
    % `builtin('@sym/factor', varargin{:})` does not work. So the following is taken from Octave's
    % `sym/factor`, with a header and a footer to call the two-output version
    nargout = 2;
    f = varargin{1};
    varargin = varargin(2:end);
    for i = 1:length(varargin)
        varargin{i} = sym(varargin{i});
    end
    if ((nargin > 1) || (~isempty (findsymbols (f))))
        % have symbols, do polynomial factorization
        if (nargout > 1)
            print_usage ();
        end
        p = python_cmd ('return factor(*_ins)', f, varargin{:});
    else
        % no symbols: we are doing integer factorization
        if (nargout <= 1)
            if (~isscalar(f))
                error('FIXME: check SMT, allows array input here?')
            end
            % this is rather fragile, as noted in docs
            p = python_cmd ('return factorint(_ins[0], visual=True),', f);
        else
            if (~isscalar(f))
                error('vector output factorization only for scalar integers')
            end
            cmd = { 'd = factorint(_ins[0], visual=False)'
                'num = len(d.keys())'
                'sk = sorted(d.keys())'
                'p = sp.Matrix(1, num, sk)'
                'm = sp.Matrix(1, num, lambda i,j: d[sk[j]])'
                'return (p, m)' };
            [p, m] = python_cmd (cmd, f);
        end
    end
    m = double(m);
    y = sym(NaN(1, sum(m)));
    k = 1;
    for h = 1:numel(m)
        y(k:k+m(h)-1) = repmat(p(h), 1, m(h));
        k = k+m(h);
    end
end
end
