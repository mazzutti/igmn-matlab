function net = copyFrom(net, other)
    net.nc = other.nc;
    net.sampleSize = other.sampleSize;
    net.priors(:, 1:net.nc) = other.priors(:, 1:other.nc);
    net.means(:, 1:net.nc) = other.means(:, 1:other.nc);
    net.covs(:, :, 1:net.nc) = other.covs(:, :, 1:other.nc);
    net.sps(:, 1:net.nc) = other.sps(:, 1:other.nc);
    net.vs(:, 1:net.nc) = other.vs(:, 1:other.nc);
    net.distances(:, 1:net.nc) = other.distances(:, 1:other.nc);
    net.logLike(:, 1:net.nc) = other.logLike(:, 1:other.nc);
    net.post(:, 1:net.nc) = other.post(:, 1:other.nc);
end